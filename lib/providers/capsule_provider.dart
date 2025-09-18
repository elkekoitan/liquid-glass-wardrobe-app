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
        final initialId = _initialSelectionId;
        if (initialId != null) {
          _selected = _capsules.firstWhere(
            (capsule) => capsule.id == initialId,
            orElse: () => _selected ?? _capsules.first,
          );
        } else if (_selected != null) {
          _selected = _capsules.firstWhere(
            (capsule) => capsule.id == _selected!.id,
            orElse: () => _capsules.first,
          );
        } else {
          _selected = _capsules.first;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCapsule(String id) {
    final candidate = _capsules.firstWhere(
      (capsule) => capsule.id == id,
      orElse: () =>
          _selected ??
          (_capsules.isNotEmpty
              ? _capsules.first
              : throw StateError('No capsules available')),
    );
    _selected = candidate;
    notifyListeners();
  }
}
