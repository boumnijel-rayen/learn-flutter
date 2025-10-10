import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
      ),
      body: Column(
        children: [
          const Text('A verification email has been sent to your email address'),
          const Text('Please verify your email address:'),
          TextButton(onPressed: () async{
            final user = FirebaseAuth.instance.currentUser;
            print(user);
            await user?.sendEmailVerification();
          }, child: const Text('Send email verification'),),
          TextButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
          }, child: const Text('Restart'),)
        ],
      ),
    );
  }
}