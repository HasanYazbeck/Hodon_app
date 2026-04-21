import '../enums/app_enums.dart';

class ChildProfile {
  final String id;
  final String parentId;
  final String name;
  final int ageMonths; // store as months for precision
  final ChildAgeGroup ageGroup;
  final String? avatarUrl;
  final String? allergies;
  final String? routines;
  final String? notes;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final DateTime createdAt;

  const ChildProfile({
    required this.id,
    required this.parentId,
    required this.name,
    required this.ageMonths,
    required this.ageGroup,
    this.avatarUrl,
    this.allergies,
    this.routines,
    this.notes,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.createdAt,
  });

  String get ageDisplay {
    if (ageMonths < 12) return '$ageMonths months';
    final years = ageMonths ~/ 12;
    final months = ageMonths % 12;
    if (months == 0) return '$years yr${years > 1 ? 's' : ''}';
    return '$years yr $months mo';
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
        id: json['id'] as String,
        parentId: json['parentId'] as String,
        name: json['name'] as String,
        ageMonths: json['ageMonths'] as int,
        ageGroup: ChildAgeGroup.values.byName(json['ageGroup'] as String),
        avatarUrl: json['avatarUrl'] as String?,
        allergies: json['allergies'] as String?,
        routines: json['routines'] as String?,
        notes: json['notes'] as String?,
        emergencyContactName: json['emergencyContactName'] as String?,
        emergencyContactPhone: json['emergencyContactPhone'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'parentId': parentId,
        'name': name,
        'ageMonths': ageMonths,
        'ageGroup': ageGroup.name,
        'avatarUrl': avatarUrl,
        'allergies': allergies,
        'routines': routines,
        'notes': notes,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'createdAt': createdAt.toIso8601String(),
      };

  ChildProfile copyWith({
    String? id,
    String? parentId,
    String? name,
    int? ageMonths,
    ChildAgeGroup? ageGroup,
    String? avatarUrl,
    String? allergies,
    String? routines,
    String? notes,
    String? emergencyContactName,
    String? emergencyContactPhone,
    DateTime? createdAt,
  }) =>
      ChildProfile(
        id: id ?? this.id,
        parentId: parentId ?? this.parentId,
        name: name ?? this.name,
        ageMonths: ageMonths ?? this.ageMonths,
        ageGroup: ageGroup ?? this.ageGroup,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        allergies: allergies ?? this.allergies,
        routines: routines ?? this.routines,
        notes: notes ?? this.notes,
        emergencyContactName: emergencyContactName ?? this.emergencyContactName,
        emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
        createdAt: createdAt ?? this.createdAt,
      );
}

