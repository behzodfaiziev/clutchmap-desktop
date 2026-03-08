import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool darkMode;
  final bool devMode;

  const AppSettings({
    required this.darkMode,
    required this.devMode,
  });

  AppSettings copyWith({
    bool? darkMode,
    bool? devMode,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      devMode: devMode ?? this.devMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode,
      'devMode': devMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      darkMode: json['darkMode'] as bool? ?? true,
      devMode: json['devMode'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [darkMode, devMode];
}



