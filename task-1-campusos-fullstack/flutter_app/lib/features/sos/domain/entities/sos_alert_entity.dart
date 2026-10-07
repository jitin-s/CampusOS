import 'package:flutter/material.dart';

enum SosEmergencyType {
  security,
  medical,
  safeWalk,
  fireHazard,
}

extension SosEmergencyTypeExtension on SosEmergencyType {
  String get title {
    switch (this) {
      case SosEmergencyType.security:
        return 'Campus Security Patrol';
      case SosEmergencyType.medical:
        return 'Medical Emergency / Ambulance';
      case SosEmergencyType.safeWalk:
        return "SafeWalk & Night Escort";
      case SosEmergencyType.fireHazard:
        return 'Fire & Hazard Alert';
    }
  }

  String get description {
    switch (this) {
      case SosEmergencyType.security:
        return 'Physical threat, suspicious activity, or intruder report';
      case SosEmergencyType.medical:
        return 'Severe illness, injury, fainting, or first aid requirement';
      case SosEmergencyType.safeWalk:
        return 'Security officer accompaniment across campus or dark corridors';
      case SosEmergencyType.fireHazard:
        return 'Fire alarm, smoke, gas odor, electrical short, or structural risk';
    }
  }

  IconData get icon {
    switch (this) {
      case SosEmergencyType.security:
        return Icons.local_police;
      case SosEmergencyType.medical:
        return Icons.medical_services;
      case SosEmergencyType.safeWalk:
        return Icons.shield;
      case SosEmergencyType.fireHazard:
        return Icons.local_fire_department;
    }
  }

  Color get color {
    switch (this) {
      case SosEmergencyType.security:
        return const Color(0xFFDC2626);
      case SosEmergencyType.medical:
        return const Color(0xFFEF4444);
      case SosEmergencyType.safeWalk:
        return const Color(0xFF2563EB);
      case SosEmergencyType.fireHazard:
        return const Color(0xFFEA580C);
    }
  }
}

enum SosDispatchStatus {
  idle,
  countingDown,
  dispatched,
  enRoute,
  resolved,
}

class SosAlertEntity {
  final String id;
  final String campusId;
  final String studentName;
  final String studentEmail;
  final SosEmergencyType type;
  final String location;
  final String? additionalNotes;
  final DateTime timestamp;
  final SosDispatchStatus status;
  final String assignedUnit;
  final String estimatedArrival;

  const SosAlertEntity({
    required this.id,
    required this.campusId,
    required this.studentName,
    required this.studentEmail,
    required this.type,
    required this.location,
    this.additionalNotes,
    required this.timestamp,
    required this.status,
    required this.assignedUnit,
    required this.estimatedArrival,
  });

  SosAlertEntity copyWith({
    String? id,
    String? campusId,
    String? studentName,
    String? studentEmail,
    SosEmergencyType? type,
    String? location,
    String? additionalNotes,
    DateTime? timestamp,
    SosDispatchStatus? status,
    String? assignedUnit,
    String? estimatedArrival,
  }) {
    return SosAlertEntity(
      id: id ?? this.id,
      campusId: campusId ?? this.campusId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      type: type ?? this.type,
      location: location ?? this.location,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      assignedUnit: assignedUnit ?? this.assignedUnit,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
    );
  }
}

class CampusEmergencyContact {
  final String name;
  final String role;
  final String phoneNumber;
  final String extension;
  final IconData icon;

  const CampusEmergencyContact({
    required this.name,
    required this.role,
    required this.phoneNumber,
    required this.extension,
    required this.icon,
  });
}
