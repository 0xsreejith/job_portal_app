import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

class JobSeekerProfile {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? location;
  final String? bio;
  final String? headline;
  final List<String> skills;
  final String? experienceLevel; // Entry, Mid, Senior, etc.
  final String? education;
  final String? resumeUrl; // URL to the resume file
  final String? profileImageUrl;
  final List<String> workExperience; // List of work experience IDs or JSON strings
  final List<String> educationHistory; // List of education history IDs or JSON strings
  final List<String> certifications; // List of certifications
  final DateTime? dateOfBirth;
  final String? gender;
  final List<String> languages;
  final String? website;
  final List<String> savedJobs; // List of job IDs
  final List<String> appliedJobs; // List of application IDs
  final DateTime createdAt;
  final DateTime updatedAt;

  JobSeekerProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.location,
    this.bio,
    this.headline,
    List<String>? skills,
    this.experienceLevel,
    this.education,
    this.resumeUrl,
    this.profileImageUrl,
    List<String>? workExperience,
    List<String>? educationHistory,
    List<String>? certifications,
    this.dateOfBirth,
    this.gender,
    List<String>? languages,
    this.website,
    List<String>? savedJobs,
    List<String>? appliedJobs,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : skills = skills ?? [],
        workExperience = workExperience ?? [],
        educationHistory = educationHistory ?? [],
        certifications = certifications ?? [],
        languages = languages ?? [],
        savedJobs = savedJobs ?? [],
        appliedJobs = appliedJobs ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert JobSeekerProfile to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'location': location,
      'bio': bio,
      'headline': headline,
      'skills': skills,
      'experienceLevel': experienceLevel,
      'education': education,
      'resumeUrl': resumeUrl,
      'profileImageUrl': profileImageUrl,
      'workExperience': workExperience,
      'educationHistory': educationHistory,
      'certifications': certifications,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'languages': languages,
      'website': website,
      'savedJobs': savedJobs,
      'appliedJobs': appliedJobs,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create JobSeekerProfile from a Map
  factory JobSeekerProfile.fromMap(Map<String, dynamic> map) {
    return JobSeekerProfile(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      location: map['location'],
      bio: map['bio'],
      headline: map['headline'],
      skills: List<String>.from(map['skills'] ?? []),
      experienceLevel: map['experienceLevel'],
      education: map['education'],
      resumeUrl: map['resumeUrl'],
      profileImageUrl: map['profileImageUrl'],
      workExperience: List<String>.from(map['workExperience'] ?? []),
      educationHistory: List<String>.from(map['educationHistory'] ?? []),
      certifications: List<String>.from(map['certifications'] ?? []),
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      gender: map['gender'],
      languages: List<String>.from(map['languages'] ?? []),
      website: map['website'],
      savedJobs: List<String>.from(map['savedJobs'] ?? []),
      appliedJobs: List<String>.from(map['appliedJobs'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create a copy of JobSeekerProfile with updated fields
  JobSeekerProfile copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? location,
    String? bio,
    String? headline,
    List<String>? skills,
    String? experienceLevel,
    String? education,
    String? resumeUrl,
    String? profileImageUrl,
    List<String>? workExperience,
    List<String>? educationHistory,
    List<String>? certifications,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? languages,
    String? website,
    List<String>? savedJobs,
    List<String>? appliedJobs,
    DateTime? updatedAt,
  }) {
    return JobSeekerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      headline: headline ?? this.headline,
      skills: skills ?? this.skills,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      education: education ?? this.education,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      workExperience: workExperience ?? this.workExperience,
      educationHistory: educationHistory ?? this.educationHistory,
      certifications: certifications ?? this.certifications,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      languages: languages ?? this.languages,
      website: website ?? this.website,
      savedJobs: savedJobs ?? this.savedJobs,
      appliedJobs: appliedJobs ?? this.appliedJobs,
      createdAt: createdAt, // Keep original created date
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
