import 'package:flutter/material.dart';
import 'package:notes_todo_app/core/model/note_model.dart';
import 'package:provider/provider.dart';

import '../../../core/controller/providers/note_provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    final timestamp = DateTime.now().toString();
    final newNote = Note(
      id: widget.note?.id,
      title: title,
      content: content,
      timestamp: timestamp,
    );

    final provider = Provider.of<NoteProvider>(context, listen: false);
    if (widget.note == null) {
      provider.addNote(newNote);
    } else {
      provider.updateNote(newNote);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _saveNote,
              child: Container(
                width: 150,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Center(child: Text("Save", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),))),
            )
          ],
        ),
      ),
    );
  }
}
