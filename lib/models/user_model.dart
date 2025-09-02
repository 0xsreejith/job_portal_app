class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String userType; // 'job_seeker' or 'employer'
  final String? photoUrl;
  final String? resumeUrl;
  final List<String>? skills;
  final int? experienceYears;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.userType,
    this.photoUrl,
    this.resumeUrl,
    this.skills,
    this.experienceYears,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'userType': userType,
      'photoUrl': photoUrl,
      'resumeUrl': resumeUrl,
      'skills': skills ?? [],
      'experienceYears': experienceYears ?? 0,
      'createdAt': DateTime.now().toIso8601String(),
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

    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      userType: map['userType']?.toString() ?? 'job_seeker',
      photoUrl: map['photoUrl']?.toString(),
      resumeUrl: map['resumeUrl']?.toString(),
      skills: parseSkills(map['skills']),
      experienceYears: map['experienceYears'] is int 
          ? map['experienceYears'] as int 
          : int.tryParse((map['experienceYears'] ?? '0').toString()) ?? 0,
    );
  }
}
