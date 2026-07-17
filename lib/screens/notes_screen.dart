import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../db/database_helper.dart';
import '../models/note.dart';

// NotesScreen is the Task 2 "SQLite SQL Screen": it demonstrates full CRUD
// (Create, Read, Update, Delete) against a local SQLite database via
// DatabaseHelper, plus a one-tap bulk import from a bundled JSON asset.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _db = DatabaseHelper.instance;
  List<Note> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  // READ: reloads the list from SQLite and rebuilds the UI.
  Future<void> _refresh() async {
    setState(() => _loading = true);
    final notes = await _db.getAllNotes();
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  // Opens the JSON asset bundled at assets/notes.json, decodes it, and bulk
  // inserts every entry as a new row - this is the "quick import from JSON"
  // requirement from Task 2.
  Future<void> _importFromJson() async {
    final raw = await rootBundle.loadString('assets/notes.json');
    final List<dynamic> decoded = jsonDecode(raw);
    final imported = decoded
        .map((entry) => Note.fromJson(entry as Map<String, dynamic>))
        .toList();

    await _db.deleteAllNotes();
    await _db.insertNotes(imported);
    await _refresh();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported ${imported.length} notes from JSON')),
    );
  }

  // CREATE / UPDATE: shared dialog used for both adding a new note and
  // editing an existing one. Passing an existing [note] switches it to
  // edit mode.
  Future<void> _showNoteDialog({Note? note}) async {
    final titleController = TextEditingController(text: note?.title ?? '');
    final descController = TextEditingController(
      text: note?.description ?? '',
    );
    bool done = note?.done ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(note == null ? 'Add Note' : 'Edit Note'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Done'),
                    value: done,
                    onChanged: (value) {
                      setDialogState(() => done = value ?? false);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;
    if (titleController.text.trim().isEmpty) return;

    if (note == null) {
      // CREATE: SQL INSERT via DatabaseHelper.insertNote
      await _db.insertNote(
        Note(
          title: titleController.text.trim(),
          description: descController.text.trim(),
          done: done,
        ),
      );
    } else {
      // UPDATE: SQL UPDATE via DatabaseHelper.updateNote
      await _db.updateNote(
        note.copyWith(
          title: titleController.text.trim(),
          description: descController.text.trim(),
          done: done,
        ),
      );
    }
    await _refresh();
  }

  // DELETE: SQL DELETE via DatabaseHelper.deleteNote, after confirmation.
  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text('Delete "${note.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _db.deleteNote(note.id!);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Notes (CRUD)'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Import from JSON',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _importFromJson,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No notes yet.'),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _importFromJson,
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Import sample data from JSON'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return ListTile(
                      leading: Checkbox(
                        value: note.done,
                        onChanged: (value) async {
                          // UPDATE: toggling the checkbox updates the row.
                          await _db.updateNote(
                            note.copyWith(done: value ?? false),
                          );
                          await _refresh();
                        },
                      ),
                      title: Text(
                        note.title,
                        style: TextStyle(
                          decoration:
                              note.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(note.description),
                      onTap: () => _showNoteDialog(note: note),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteNote(note),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
