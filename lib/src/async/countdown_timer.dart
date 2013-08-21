// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of quiver.async;

/**
 * A simple countdown timer that fires events in configurable increments.
 *
 * CountdownTimer implements [Stream] and sends itself as the event. From the
 * timer you can get the [remaining] and [elapsed] time, or [cancel] the timer.
 */
class CountdownTimer extends Stream<CountdownTimer> {
  final Duration _duration;
  final Duration _increment;
  final Stopwatch _stopwatch;
  final StreamController<CountdownTimer> _controller;
  Timer _timer;

  CountdownTimer(Duration duration, Duration increment)
      : _duration = duration,
        _increment = increment,
        _stopwatch = new Stopwatch(),
        _controller = new StreamController<CountdownTimer>.broadcast() {
    _timer = new Timer.periodic(increment, _tick);
    _stopwatch.start();
  }

  StreamSubscription<CountdownTimer> listen(void onData(CountdownTimer event), {
      void onError(error), void onDone(), bool cancelOnError}) =>
          _controller.stream.listen(onData, onError: onError, onDone: onDone);

  Duration get elapsed => _stopwatch.elapsed;

  Duration get remaining => _duration - _stopwatch.elapsed;

  bool get isRunning => _stopwatch.isRunning;

  cancel() {
    _stopwatch.stop();
    _timer.cancel();
    _controller.close();
  }

  _tick(Timer timer) {
    var t = remaining;
    _controller.add(this);
    if (t.inMicroseconds <= 0) {
      cancel();
    }
  }
}