import 'package:flutter/material.dart';

import 'package:notes_todo_app/core/db/db_helper.dart';
import 'package:notes_todo_app/core/model/note_model.dart';


class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  Future<void> loadNotes() async {
    _notes = await DBHelper.getNotes();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await DBHelper.insertNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await DBHelper.deleteNote(id);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await DBHelper.updateNote(note);
    await loadNotes();
  }
}
