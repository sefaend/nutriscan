/// Giriş yapmış kullanıcının ekranların ihtiyacı olan kısa hali.
/// (Firebase'in User sınıfı ekranlara sızmasın diye repository bunu döndürür.)
class AppUser {
  const AppUser({required this.uid, required this.name, required this.email});

  final String uid;

  /// Görünen ad. Ad yoksa e-postanın @ öncesi.
  final String name;
  final String email;
}
