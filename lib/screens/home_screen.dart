import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:notes_todo_app/model/note_model.dart';
import 'package:notes_todo_app/services/drive_services.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context);
    final driveService = DriveService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.backup),
            tooltip: 'Backup to Drive',
            onPressed: () async {
              try {
                await driveService.signIn();
                final notes = provider.notes.map((e) => e.toMap()).toList();
                final jsonData = jsonEncode(notes);
                await driveService.uploadJson('notes_backup.json', jsonData);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup Complete')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Backup Failed: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Restore from Drive',
            onPressed: () async {
              try {
                await driveService.signIn();
                final json = await driveService.downloadBackupFile('notes_backup.json');
                if (json != null) {
                  final List decoded = jsonDecode(json);
                  for (var item in decoded) {
                    final note = Note.fromMap(item);
                    await provider.addNote(note);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Restore Complete')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No backup file found')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Restore Failed: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: provider.loadNotes(),
        builder: (context, snapshot) {
          if (provider.notes.isEmpty) {
            return const Center(child: Text('No notes found.'));
          }
          return ListView.builder(
            itemCount: provider.notes.length,
            itemBuilder: (context, index) {
              final note = provider.notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(note.timestamp),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditNoteScreen(note: note),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteNote(note.id!),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
