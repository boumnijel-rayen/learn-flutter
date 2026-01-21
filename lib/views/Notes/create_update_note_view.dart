import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/Utilities/generics/get_arguments.dart';
import 'package:learn_flutter/services/auth/auth_service.dart';
import 'package:learn_flutter/services/cloud/cloud_note.dart';
import 'package:learn_flutter/services/cloud/firebase_cloud_storage.dart';

class NewNotesView extends StatefulWidget {
  const NewNotesView({super.key});

  @override
  State<NewNotesView> createState() => _NewNotesViewState();
}

class _NewNotesViewState extends State<NewNotesView> {
  CloudNote? _note;
  late final FireBaseCloudStorage _noteService;
  late final TextEditingController _textController;

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {

    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null){
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _noteService.createNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _noteService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;

    if (note !=null && text.isNotEmpty){
      await _noteService.updateNote(documentId: note.documentId, text: text);
    }
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  @override
  void dispose(){
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _noteService = FireBaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null){
      return;
    }
    final text = _textController.text;
    await _noteService.updateNote(documentId: note.documentId, text: text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Notes'),
      ),
      body: FutureBuilder(
          future: createOrGetExistingNote(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _note = snapshot.data as CloudNote;
                _setupTextControllerListener();
                return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLength: null,
                  decoration: const InputDecoration(
                    hintText: 'Start typing your note...',
                  ),
                );
              default :
                return const CircularProgressIndicator();
            }
          },
      ),
    );
  }
}
