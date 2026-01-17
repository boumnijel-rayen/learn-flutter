import 'package:flutter/material.dart';
import 'package:learn_flutter/services/auth/auth_service.dart';
import 'package:learn_flutter/views/Notes/create_update_note_view.dart';
import 'package:learn_flutter/views/login_view.dart';
import 'package:learn_flutter/views/Notes/notes_view.dart';
import 'package:learn_flutter/views/register_view.dart';
import 'package:learn_flutter/views/verify_email_view.dart';

import 'constants/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      home: const HomePage(),
      routes: {
        loginRoute : (context) => const LoginView(),
        registerRoute : (context) => const RegisterView(),
        notesRoute : (context) => const NotesView(),
        verifyEmail : (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute : (context) => const NewNotesView(),
      },
    )
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null){
                if (user.isEmailVerified){
                  return const NotesView();
                }else{
                  return const VerifyEmailView();
                }
              }else{
                return const LoginView();
              }
            default :
              return const Text("Loading...");
          }

        }
    );
  }
}