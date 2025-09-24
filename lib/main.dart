import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/views/login_view.dart';
import 'package:learn_flutter/views/register_view.dart';
import 'package:learn_flutter/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;

import 'constants/routes.dart';
import 'firebase_options.dart';

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
      },
    )
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> waitTenSeconds() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: waitTenSeconds(),
        builder: (context, asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null){
                if (user.emailVerified){
                  return const LoginView();
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


enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async{
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                devtools.log(shouldLogout.toString());
                if (shouldLogout){
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                }
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem(value: MenuAction.logout, child: Text('Logout'))
            ];
          },)
        ]
      ),
      body: const Text('Notes'),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
 return showDialog<bool>(
   context: context,
   builder: (context) {
     return AlertDialog(
       title: const Text('Sign out'),
       content: const Text('Are you sure you want to sign out?'),
       actions: [
         TextButton(
             onPressed: () {
               Navigator.of(context).pop(false);
             },
             child: const Text('Cancel')
         ),
        TextButton(onPressed: () {
          Navigator.of(context).pop(true);
        }, child: const Text('LogOut')
        ),
       ],
     );
   },
 ).then((value) => value ?? false);
}