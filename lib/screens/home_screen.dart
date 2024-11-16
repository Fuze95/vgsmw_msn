import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MySimpleNote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Implement settings
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          final notes = noteProvider.notes;

          if (notes.isEmpty) {
            return const Center(
              child: Text('No notes yet. Create your first note!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return NoteCard(
                note: notes[index],
                onArchive: () {
                  noteProvider.toggleArchiveStatus(notes[index]);
                },
                onDelete: () async {
                  await noteProvider.deleteNote(notes[index].id!);
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
            MaterialPageRoute(
              builder: (context) => const NoteEditorScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Add search delegate class
class NoteSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    noteProvider.setSearchQuery(query);

    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        final filteredNotes = noteProvider.getFilteredNotes();

        if (filteredNotes.isEmpty) {
          return const Center(
            child: Text('No matching notes found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: filteredNotes.length,
          itemBuilder: (context, index) {
            return NoteCard(
              note: filteredNotes[index],
              onArchive: () {
                noteProvider.toggleArchiveStatus(filteredNotes[index]);
              },
              onDelete: () async {
                await noteProvider.deleteNote(filteredNotes[index].id!);
              },
            );
          },
        );
      },
    );
  }
}