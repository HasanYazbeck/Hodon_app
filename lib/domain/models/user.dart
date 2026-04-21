import '../enums/user_role.dart';
import '../enums/app_enums.dart';

class UserAddress {
  final String id;
  final String label;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const UserAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
        id: json['id'] as String,
        label: json['label'] as String,
        fullAddress: json['fullAddress'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        isDefault: json['isDefault'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'fullAddress': fullAddress,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
      };

  UserAddress copyWith({
    String? id,
    String? label,
    String? fullAddress,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) =>
      UserAddress(
        id: id ?? this.id,
        label: label ?? this.label,
        fullAddress: fullAddress ?? this.fullAddress,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isDefault: isDefault ?? this.isDefault,
      );
}

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? avatarUrl;
  final String? phone;
  final String? bio;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final UserAddress? address;
  final bool isEmailVerified;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.phone,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.isEmailVerified = false,
    this.isProfileComplete = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get firstName => fullName.split(' ').first;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['fullName'] as String,
        role: UserRole.values.byName(json['role'] as String),
        avatarUrl: json['avatarUrl'] as String?,
        phone: json['phone'] as String?,
        bio: json['bio'] as String?,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.parse(json['dateOfBirth'] as String)
            : null,
        gender: json['gender'] != null
            ? Gender.values.byName(json['gender'] as String)
            : null,
        address: json['address'] != null
            ? UserAddress.fromJson(json['address'] as Map<String, dynamic>)
            : null,
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
        isProfileComplete: json['isProfileComplete'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'role': role.name,
        'avatarUrl': avatarUrl,
        'phone': phone,
        'bio': bio,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': gender?.name,
        'address': address?.toJson(),
        'isEmailVerified': isEmailVerified,
        'isProfileComplete': isProfileComplete,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    String? avatarUrl,
    String? phone,
    String? bio,
    DateTime? dateOfBirth,
    Gender? gender,
    UserAddress? address,
    bool? isEmailVerified,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      AppUser(
        id: id ?? this.id,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
        role: role ?? this.role,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        phone: phone ?? this.phone,
        bio: bio ?? this.bio,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        gender: gender ?? this.gender,
        address: address ?? this.address,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        isProfileComplete: isProfileComplete ?? this.isProfileComplete,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

