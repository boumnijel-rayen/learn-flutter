import 'package:flutter/material.dart';
import 'package:learn_flutter/services/cloud/cloud_note.dart';
import 'package:learn_flutter/views/Notes/notes_list_view.dart';
import 'dart:developer' as devtools show log;

import '../../Utilities/dialogs/logout_dialog.dart';
import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../services/auth/auth_service.dart';
import '../../services/cloud/firebase_cloud_storage.dart';


class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FireBaseCloudStorage _noteService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _noteService = FireBaseCloudStorage();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Notes'),
          actions: [
            IconButton(
                onPressed: (){
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
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
      body: StreamBuilder(
          stream: _noteService.allNotes(ownerUserId: userId),
          builder: (context, snapshot){
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData){
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _noteService.deleteNote(documentId: note.documentId);
                    },
                    onTap: (CloudNote note) {
                      Navigator.of(context).pushNamed(createOrUpdateNoteRoute, arguments: note);
                    },
                  );

                }else{
                  return const CircularProgressIndicator();
                }
              default:
                return const CircularProgressIndicator();
            }
          }),
    );
  }
}