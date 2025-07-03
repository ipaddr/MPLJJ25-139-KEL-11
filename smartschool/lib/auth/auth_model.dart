// Model ini bisa diperluas jika ada data pendaftaran tambahan yang diperlukan
class AuthModel {
  final String email;
  final String password;

  AuthModel({required this.email, required this.password});
}
