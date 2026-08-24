import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/momentum_counter.dart';

void main() {
  test('starts at zero', () {
    final momentum = MomentumCounter();

    expect(momentum.chainLength, 0);
  });

  test('recordCompletion increments the chain', () {
    final momentum = MomentumCounter();

    momentum.recordCompletion();
    momentum.recordCompletion();
    momentum.recordCompletion();
    momentum.recordCompletion();

    expect(momentum.chainLength, 4);
  });

  test('reset clears the chain back to zero', () {
    final momentum = MomentumCounter();
    momentum.recordCompletion();
    momentum.recordCompletion();

    momentum.reset();

    expect(momentum.chainLength, 0);
  });
}
