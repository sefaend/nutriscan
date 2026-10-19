/// Uygulama genelinde açıp kapatılabilen ayarlar.
class AppConfig {
  AppConfig._();

  /// true  -> Giriş/kayıt sahte (mock) servisle çalışır, Firebase gerekmez.
  ///          Arayüzü simülatörde denemek için ideal.
  /// false -> Gerçek Firebase Auth kullanılır.
  static const bool useMockAuth = true;
}
