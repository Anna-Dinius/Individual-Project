import 'package:flutter/foundation.dart';

/// Holds the currently selected allergen IDs so selection persists across screens.
class AllergenSelectionProvider extends ChangeNotifier {
  Set<String> _selectedIds = {};

  Set<String> get selectedIds => _selectedIds;

  void setSelectedIds(Set<String> ids) {
    _selectedIds = {...ids};
    notifyListeners();
  }

  void clear() {
    if (_selectedIds.isNotEmpty) {
      _selectedIds.clear();
      notifyListeners();
    }
  }

  void toggle(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }
}
