import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartschool/models/user_model.dart'; // Import model User

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        DocumentSnapshot userDoc =
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();
        if (userDoc.exists) {
          return UserModel.fromDocumentSnapshot(userDoc);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Pengguna tidak ditemukan untuk email tersebut.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Kata sandi salah.');
      } else {
        throw Exception('Gagal masuk: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  Future<void> signOut() async {
    // <<<--- Metode signOut ini
    await _firebaseAuth.signOut();
  }

  // Fungsi untuk mendapatkan user saat ini (jika sudah login)
  User? getCurrentUser() {
    // <<<--- Metode getCurrentUser ini
    return _firebaseAuth.currentUser;
  }

  // Fungsi untuk membuat user baru (hanya untuk testing/setup awal)
  // Di aplikasi nyata, pendaftaran mungkin ditangani oleh admin atau ada flow yang berbeda
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String role,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        UserModel newUser = UserModel(
          id: userCredential.user!.uid,
          email: email,
          name: name,
          role: role,
        );
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());
        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Kata sandi terlalu lemah.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Akun sudah ada untuk email tersebut.');
      } else {
        throw Exception('Gagal mendaftar: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }
}
