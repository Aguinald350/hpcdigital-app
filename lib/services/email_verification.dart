import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> registrarEnviarVerificacao({
  required String email,
  required String senha,
}) async {
  final auth = FirebaseAuth.instance;

  // Define idioma do e-mail (apenas se for enviado)
  await auth.setLanguageCode('pt');

  final cred = await auth.createUserWithEmailAndPassword(
    email: email.trim(),
    password: senha,
  );

  final user = cred.user;

  // 🔹 E-mails de administradores que não precisam verificar
  const admins = [
    'admin@hpc.com',
    'aguinaldo@igreja.org',
  ];

  if (user != null && !user.emailVerified) {
    final emailLower = email.trim().toLowerCase();
    // ✅ Só envia verificação se NÃO for admin
    if (!admins.contains(emailLower)) {
      await user.sendEmailVerification();
    }
  }

  return cred;
}
