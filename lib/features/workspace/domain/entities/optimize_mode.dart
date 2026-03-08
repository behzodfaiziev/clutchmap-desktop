enum OptimizeMode {
  safe,
  robust,
  minimalChange,
}

extension OptimizeModeExtension on OptimizeMode {
  String toBackendValue() {
    switch (this) {
      case OptimizeMode.safe:
        return 'SAFE';
      case OptimizeMode.robust:
        return 'ROBUST';
      case OptimizeMode.minimalChange:
        return 'MINIMAL_CHANGE';
    }
  }

  String get displayName {
    switch (this) {
      case OptimizeMode.safe:
        return 'SAFE';
      case OptimizeMode.robust:
        return 'ROBUST';
      case OptimizeMode.minimalChange:
        return 'MINIMAL CHANGE';
    }
  }
}



