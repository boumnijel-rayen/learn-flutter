import 'package:flutter/material.dart';
import 'package:learn_flutter/services/crud/notes_servie.dart';
import 'dart:developer' as devtools show log;

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../services/auth/auth_service.dart';


class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NoteService _noteService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _noteService = NoteService();
    _noteService.open();
    super.initState();
  }

  @override
  void dispose() {
    _noteService.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Notes'),
          actions: [
            IconButton(
                onPressed: (){
                  Navigator.of(context).pushNamed(newNoteRoute);
                },
                icon: const Icon(Icons.add)
            ),
            PopupMenuButton<MenuAction>(onSelected: (value) async{
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  devtools.log(shouldLogout.toString());
                  if (shouldLogout){
                    await AuthService.firebase().logOut();
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
      body: FutureBuilder(
          future: _noteService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch(snapshot.connectionState){
              case ConnectionState.done:
                return StreamBuilder(
                    stream: _noteService.allNotes,
                    builder: (context, snapshot){
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Text('Waiting for all notes ...');
                        default:
                          return const CircularProgressIndicator();
                      }
                    });
              default:
                return const CircularProgressIndicator();
            }
          },
      ),
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