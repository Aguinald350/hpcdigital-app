import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista de emails que serão considerados administradores
  final List<String> _adminEmails = [
    'admin@hpc.com',
    'aguinaldo@igreja.org',
  ];

  Future<String?> registerUser({
    required String nome,
    required String email,
    required String senha,
    required String confirmarSenha,
    required String igreja,
    required String organismo,
  }) async {
    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty || igreja.isEmpty || organismo.isEmpty) {
      return 'Por favor, preencha todos os campos.';
    }

    if (senha != confirmarSenha) {
      return 'As senhas não coincidem.';
    }

    try {
      // Criar usuário no Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Verifica se o email pertence à lista de administradores
      final String role = _adminEmails.contains(email.toLowerCase()) ? 'admin' : 'user';

      // Salvar dados no Firestore
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': nome,
        'email': email,
        'igreja': igreja,
        'organismo': organismo,
        'role': role,
        'criado_em': Timestamp.now(),
      });

      return null; // sucesso
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'Erro inesperado. Tente novamente.';
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este email já está em uso.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      default:
        return 'Erro de autenticação: $code';
    }
  }
}
