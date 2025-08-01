import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:notes_todo_app/core/model/note_model.dart';
import 'package:notes_todo_app/core/services/drive_services.dart';
import 'package:provider/provider.dart';
import '../../../core/controller/providers/note_provider.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<int> selectedIndexes = {};

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context);
    final driveService = DriveService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Selected',
            onPressed: () async {
              final idsToDelete = selectedIndexes
                  .map((index) => provider.notes[index].id)
                  .whereType<int>()
                  .toList();

              for (final id in idsToDelete) {
                await provider.deleteNote(id);
              }

              setState(() {
                selectedIndexes.clear();
              });
            },
          ),
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
              final isSelected = selectedIndexes.contains(index);

              return ListTile(
                title: Text(note.title),
                subtitle: Text(note.timestamp),
                tileColor: isSelected ? Colors.blue.shade100 : null,
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedIndexes.remove(index);
                    } else {
                      selectedIndexes.add(index);
                    }
                  });
                },
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
