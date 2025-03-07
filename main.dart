import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite CRUD',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() async {
    final data = await dbHelper.readAllNotes();
    setState(() {
      notes = data;
    });
  }

  void _addNote() async {
    final note = {
      'title': titleController.text,
      'description': descriptionController.text,
    };
    await dbHelper.create(note);
    titleController.clear();
    descriptionController.clear();
    _refreshNotes();
  }

  void _updateNote(Map<String, dynamic> note) async {
    final updatedNote = {
      'id': note['id'],
      'title': titleController.text,
      'description': descriptionController.text,
    };
    await dbHelper.update(updatedNote);
    titleController.clear();
    descriptionController.clear();
    _refreshNotes();
  }

  void _deleteNote(int id) async {
    await dbHelper.delete(id);
    _refreshNotes();
  }

  void _showForm(Map<String, dynamic>? note) {
    if (note != null) {
      titleController.text = note['title'];
      descriptionController.text = note['description'];
    } else {
      titleController.clear();
      descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (note == null) {
                  _addNote();
                } else {
                  _updateNote(note);
                }
                Navigator.of(context).pop();
              },
              child: Text(note == null ? 'Add Note' : 'Update Note'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SQLite CRUD')),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            child: ListTile(
              title: Text(note['title']),
              subtitle: Text(note['description']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.edit), onPressed: () => _showForm(note)),
                  IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteNote(note['id'])),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
