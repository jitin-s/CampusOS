import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/sos_alert_entity.dart';

class SosController extends ChangeNotifier {
  SosAlertEntity? _activeAlert;
  SosDispatchStatus _status = SosDispatchStatus.idle;
  int _countdownRemaining = 3;
  Timer? _countdownTimer;
  Timer? _simulationTimer;
  bool _strobeActive = false;
  String _selectedLocation = 'Science & Academic Block B - 3rd Floor';
  SosEmergencyType _selectedType = SosEmergencyType.security;

  final List<String> campusLocations = const [
    'Science & Academic Block B - 3rd Floor',
    'Main Engineering Complex - Lab 204',
    'Central Library - 2nd Floor Silent Zone',
    'Student Activity Center & Cafeteria',
    'Girls Hostel Block 2 - Main Gate',
    'Boys Hostel Block 1 - Quadrangle',
    'Campus Sports Arena & Gymnasium',
    'Administrative Block - Registrar Office',
    'South Campus Parking Lot B',
  ];

  final List<CampusEmergencyContact> emergencyContacts = const [
    CampusEmergencyContact(
      name: 'Campus Rapid Security Control',
      role: '24/7 Central Dispatch',
      phoneNumber: '1800-CAMPUS-911',
      extension: 'Ext 100',
      icon: Icons.shield,
    ),
    CampusEmergencyContact(
      name: 'Campus Health & Ambulance',
      role: 'Emergency Medical Officers',
      phoneNumber: '+91 11-2659-1008',
      extension: 'Ext 108',
      icon: Icons.local_hospital,
    ),
    CampusEmergencyContact(
      name: "Women's Safety & Anti-Harassment",
      role: 'Internal Complaints & SafeWalk',
      phoneNumber: '+91 11-2659-1091',
      extension: 'Toll-Free 1091',
      icon: Icons.health_and_safety,
    ),
    CampusEmergencyContact(
      name: 'Chief Proctor Emergency Desk',
      role: 'Campus Discipline & Order',
      phoneNumber: '+91 11-2659-7000',
      extension: 'Ext 7000',
      icon: Icons.security,
    ),
  ];

  SosAlertEntity? get activeAlert => _activeAlert;
  SosDispatchStatus get status => _status;
  int get countdownRemaining => _countdownRemaining;
  bool get strobeActive => _strobeActive;
  String get selectedLocation => _selectedLocation;
  SosEmergencyType get selectedType => _selectedType;
  bool get isEmergencyActive =>
      _status == SosDispatchStatus.dispatched ||
      _status == SosDispatchStatus.enRoute;

  void setSelectedLocation(String loc) {
    _selectedLocation = loc;
    notifyListeners();
  }

  void setSelectedType(SosEmergencyType type) {
    _selectedType = type;
    notifyListeners();
  }

  void toggleStrobe() {
    _strobeActive = !_strobeActive;
    notifyListeners();
  }

  /// Initiates 3-second safety countdown to cancel accidental triggers
  void startSosCountdown({
    required String studentName,
    required String studentEmail,
    String? customLocation,
    String? notes,
  }) {
    final location = customLocation ?? _selectedLocation;
    _status = SosDispatchStatus.countingDown;
    _countdownRemaining = 3;
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownRemaining > 1) {
        _countdownRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
        _dispatchSos(
          studentName: studentName,
          studentEmail: studentEmail,
          location: location,
          notes: notes,
        );
      }
    });
  }

  /// Immediately triggers emergency without countdown
  void triggerImmediateSos({
    required String studentName,
    required String studentEmail,
    String? customLocation,
    String? notes,
  }) {
    _countdownTimer?.cancel();
    _dispatchSos(
      studentName: studentName,
      studentEmail: studentEmail,
      location: customLocation ?? _selectedLocation,
      notes: notes,
    );
  }

  void _dispatchSos({
    required String studentName,
    required String studentEmail,
    required String location,
    String? notes,
  }) {
    final alertId = 'SOS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _activeAlert = SosAlertEntity(
      id: alertId,
      campusId: 'campus-alpha-001',
      studentName: studentName,
      studentEmail: studentEmail,
      type: _selectedType,
      location: location,
      additionalNotes: notes,
      timestamp: DateTime.now(),
      status: SosDispatchStatus.dispatched,
      assignedUnit: 'Campus Quick Response Force (Patrol Team Beta-04)',
      estimatedArrival: '1-3 mins',
    );
    _status = SosDispatchStatus.dispatched;
    notifyListeners();

    // Simulate transition to enRoute after 4 seconds
    _simulationTimer?.cancel();
    _simulationTimer = Timer(const Duration(seconds: 4), () {
      if (_activeAlert != null && _status == SosDispatchStatus.dispatched) {
        _status = SosDispatchStatus.enRoute;
        _activeAlert = _activeAlert!.copyWith(
          status: SosDispatchStatus.enRoute,
          estimatedArrival: 'Under 60 seconds (Officer En Route)',
        );
        notifyListeners();
      }
    });
  }

  /// Cancels countdown before dispatch happens
  void cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _status = SosDispatchStatus.idle;
    notifyListeners();
  }

  /// Resolves the emergency and sets state back to normal
  void resolveEmergency() {
    _countdownTimer?.cancel();
    _simulationTimer?.cancel();
    _strobeActive = false;
    _activeAlert = null;
    _status = SosDispatchStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _simulationTimer?.cancel();
    super.dispose();
  }
}
