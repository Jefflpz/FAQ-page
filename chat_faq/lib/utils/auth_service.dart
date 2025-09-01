import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userStream => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> cadastrarComEmailSenha(String email, String senha) async {
    try {
      UserCredential resultado = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return resultado.user;
    } on FirebaseAuthException catch (e) {
      print("Erro no cadastro: ${e.code} - ${e.message}");
      return null;
    }
  }

  Future<User?> loginComEmailSenha(String email, String senha) async {
    try {
      UserCredential resultado = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return resultado.user;
    } on FirebaseAuthException catch (e) {
      print("Erro no login: ${e.code} - ${e.message}");
      return null;
    }
  }

  Future<User?> loginComGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential resultado =
          await _auth.signInWithCredential(credential);
      return resultado.user;
    } catch (e) {
      print("Erro no login com Google: $e");
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  Future<void> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print("Erro ao recuperar senha: ${e.message}");
      rethrow;
    }
  }
}