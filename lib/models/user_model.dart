class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String userType; // 'job_seeker' or 'employer'
  final String? photoUrl;
  final String? resumeUrl;
  final String? phoneNumber;
  final String? experience;
  final List<String>? skills;
  final int? experienceYears;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.userType,
    this.photoUrl,
    this.resumeUrl,
    this.phoneNumber,
    this.experience,
    this.skills,
    this.experienceYears,
    this.createdAt,
  });

  // Getter for backward compatibility
  String? get photoURL => photoUrl;
  String? get phone => phoneNumber;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'userType': userType,
      'photoUrl': photoUrl,
      'resumeUrl': resumeUrl,
      'phoneNumber': phoneNumber,
      'experience': experience,
      'skills': skills ?? [],
      'experienceYears': experienceYears ?? 0,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Handle different types that might come from Firestore for skills
    List<String> parseSkills(dynamic skillsData) {
      if (skillsData == null) return [];
      if (skillsData is List) {
        return skillsData.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Parse date from string or timestamp
    DateTime? parseDate(dynamic dateData) {
      if (dateData == null) return null;
      if (dateData is DateTime) return dateData;
      if (dateData is String) return DateTime.tryParse(dateData);
      if (dateData is int) return DateTime.fromMillisecondsSinceEpoch(dateData);
      return null;
    }

    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? map['name']?.toString() ?? '',
      userType: map['userType']?.toString() ?? 'job_seeker',
      phoneNumber: map['phoneNumber']?.toString() ?? map['phone']?.toString(),
      experience: map['experience']?.toString(),
      createdAt: parseDate(map['createdAt']),
      photoUrl: map['photoUrl']?.toString() ?? map['photoURL']?.toString(),
      resumeUrl: map['resumeUrl']?.toString(),
      skills: parseSkills(map['skills']),
      experienceYears: map['experienceYears'] != null ? int.tryParse(map['experienceYears'].toString()) : null,
    );
  }

  // Copy with method for immutable updates
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? userType,
    String? photoUrl,
    String? resumeUrl,
    String? phoneNumber,
    String? experience,
    List<String>? skills,
    int? experienceYears,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      userType: userType ?? this.userType,
      photoUrl: photoUrl ?? this.photoUrl,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      experienceYears: experienceYears ?? this.experienceYears,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
