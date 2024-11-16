import 'package:flutter/foundation.dart';
import '../models/label.dart';
import '../database/database_handler.dart';

class LabelProvider with ChangeNotifier {
  List<Label> _labels = [];
  List<Label> get labels => _labels;

  final DatabaseHandler _databaseHandler;

  LabelProvider(this._databaseHandler) {
    _loadLabels();
  }

  Future<void> _loadLabels() async {
    _labels = await _databaseHandler.getLabels();
    notifyListeners();
  }

  Future<void> addLabel(Label label) async {
    await _databaseHandler.insertLabel(label);
    await _loadLabels();
  }

  Future<void> updateLabel(Label label) async {
    await _databaseHandler.updateLabel(label);
    await _loadLabels();
  }

  Future<void> deleteLabel(int id) async {
    await _databaseHandler.deleteLabel(id);
    await _loadLabels();
  }
}