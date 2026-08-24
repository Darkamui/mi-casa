class MomentumCounter {
  int _chainLength = 0;

  int get chainLength => _chainLength;

  void recordCompletion() {
    _chainLength += 1;
  }

  void reset() {
    _chainLength = 0;
  }
}
