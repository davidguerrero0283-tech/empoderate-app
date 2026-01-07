class AppFeatures {
  // Prevent instantiation
  AppFeatures._();

  /// Controls if the Premium Store and Plans are visible.
  /// Set to false for MVP to hide "Próximamente" sections.
  static const bool premiumStoreEnabled = false;

  /// Controls if the Library is enabled.
  static const bool libraryEnabled = true;

  /// Controls if the "Ruta al Éxito" gamification is enabled.
  static const bool rutaEnabled = true;

  /// Controls if the Blog is enabled (we know it is, but for completeness).
  static const bool blogEnabled = true;
}
