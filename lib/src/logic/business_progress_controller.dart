import 'dart:async';
import 'package:flutter/material.dart';
import '../data/repositories/checklist_repository.dart';
import '../models/checklist_model.dart';
import '../services/progress_tracker_service.dart';

class BusinessProgressController extends ChangeNotifier {
  final ChecklistRepository _repository = ChecklistRepository();
  
  BusinessProgressModel _currentData = BusinessProgressModel.empty;
  BusinessProgressModel get data => _currentData;
  
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  StreamSubscription? _subscription;
  StreamSubscription? _progressSubscription;

  void init() {
    _isLoading = true;
    notifyListeners();

    // Initial Load
    _repository.init().then((_) {
       _currentData = _repository.currentDashboard;
       _isLoading = false;
       notifyListeners();
    });

    // Listen for repository updates
    _subscription = _repository.watchDashboard.listen((newData) {
      _currentData = newData;
      _isLoading = false;
      notifyListeners();
    });

    // ✨ NEW: Listen for progress tracker updates
    _progressSubscription = ProgressTrackerService.instance.progressUpdates.listen((newProgress) {
      print('🔄 HomeScreen: Progress update received, refreshing dashboard...');
      refresh();
    });
  }

  void refresh() {
    _repository.refresh();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _progressSubscription?.cancel();
    super.dispose();
  }
}
