enum UserRole { parent, babysitter }

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.parent => 'Parent',
        UserRole.babysitter => 'Babysitter',
      };

  bool get isParent => this == UserRole.parent;
  bool get isBabysitter => this == UserRole.babysitter;
}

