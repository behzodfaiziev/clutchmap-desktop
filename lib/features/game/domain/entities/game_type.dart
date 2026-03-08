enum GameType {
  valorant,
  cs2,
}

extension GameTypeExtension on GameType {
  String get name {
    switch (this) {
      case GameType.valorant:
        return 'VALORANT';
      case GameType.cs2:
        return 'CS2';
    }
  }

  static GameType? fromString(String value) {
    switch (value.toUpperCase()) {
      case 'VALORANT':
        return GameType.valorant;
      case 'CS2':
        return GameType.cs2;
      default:
        return null;
    }
  }
}


