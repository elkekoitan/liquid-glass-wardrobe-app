import 'package:flutter/foundation.dart';

import '../models/capsule_model.dart';
import '../services/capsule_service.dart';

class CapsuleProvider extends ChangeNotifier {
  CapsuleProvider({CapsuleService? service, String? initialSelectionId})
    : _service = service ?? CapsuleService.instance,
      _initialSelectionId = initialSelectionId;

  final CapsuleService _service;
  final String? _initialSelectionId;

  List<CapsuleModel> _capsules = const [];
  CapsuleModel? _selected;
  bool _isLoading = false;
  String? _error;

  List<CapsuleModel> get capsules => _capsules;
  CapsuleModel? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.loadCapsules(forceRefresh: refresh);
      _capsules = result;

      if (_capsules.isEmpty) {
        _selected = null;
      } else {
        final String? preferredId = _initialSelectionId ?? _selected?.id;
        _selected = _pickSelectable(preferredId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCapsule(String id) {
    final capsule = _pickSelectable(id);
    if (capsule == null) {
      return;
    }
    _selected = capsule;
    notifyListeners();
  }

  CapsuleModel? _pickSelectable(String? preferredId) {
    if (_capsules.isEmpty) {
      return null;
    }

    if (preferredId != null) {
      for (final capsule in _capsules) {
        if (capsule.id == preferredId && capsule.isSelectable) {
          return capsule;
        }
      }
    }

    for (final capsule in _capsules) {
      if (capsule.isSelectable) {
        return capsule;
      }
    }

    return _capsules.first;
  }
}
