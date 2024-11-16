import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/label_provider.dart';
import '../models/label.dart';

class LabelManagementScreen extends StatelessWidget {
  const LabelManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Labels'),
      ),
      body: Consumer<LabelProvider>(
        builder: (context, labelProvider, child) {
          return ListView.builder(
            itemCount: labelProvider.labels.length,
            itemBuilder: (context, index) {
              final label = labelProvider.labels[index];
              return ListTile(
                leading: Icon(Icons.label,
                    color: label.color != null
                        ? Color(int.parse(label.color!))
                        : null),
                title: Text(label.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteLabel(context, labelProvider, label),
                ),
                onTap: () => _editLabel(context, labelProvider, label),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addLabel(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addLabel(BuildContext context) async {
    final nameController = TextEditingController();
    final result = await showDialog<Label>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Label'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Label Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(
                  context,
                  Label(name: nameController.text),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      Provider.of<LabelProvider>(context, listen: false).addLabel(result);
    }
  }

  Future<void> _editLabel(
      BuildContext context, LabelProvider provider, Label label) async {
    final nameController = TextEditingController(text: label.name);
    final result = await showDialog<Label>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Label'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Label Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(
                  context,
                  Label(
                    id: label.id,
                    name: nameController.text,
                    color: label.color,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      provider.updateLabel(result);
    }
  }

  Future<void> _deleteLabel(
      BuildContext context, LabelProvider provider, Label label) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Label'),
        content: Text('Are you sure you want to delete "${label.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && label.id != null) {
      provider.deleteLabel(label.id!);
    }
  }
}