import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String employerId;
  final String title;
  final String description;
  final String location;
  final double salary;
  final String jobType; // Full-time, Part-time, Contract, etc.
  final List<String> requirements;
  final List<String> skillsRequired;
  final DateTime postedDate;
  final DateTime? applicationDeadline;
  final bool isActive;
  final String? companyName;
  final String? companyLogo;
  final String? experienceLevel; // Entry, Mid, Senior, etc.
  final String? category; // IT, Marketing, Design, etc.

  JobModel({
    this.id = '',
    required this.employerId,
    required this.title,
    required this.description,
    required this.location,
    required this.salary,
    required this.jobType,
    required this.requirements,
    required this.skillsRequired,
    DateTime? postedDate,
    this.applicationDeadline,
    this.isActive = true,
    this.companyName,
    this.companyLogo,
    this.experienceLevel,
    this.category,
  }) : postedDate = postedDate ?? DateTime.now();

  // Convert JobModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employerId': employerId,
      'title': title,
      'description': description,
      'location': location,
      'salary': salary,
      'jobType': jobType,
      'requirements': requirements,
      'skillsRequired': skillsRequired,
      'postedDate': Timestamp.fromDate(postedDate),
      'applicationDeadline': applicationDeadline != null 
          ? Timestamp.fromDate(applicationDeadline!)
          : null,
      'isActive': isActive,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'experienceLevel': experienceLevel,
      'category': category,
    };
  }

  // Create JobModel from a Map
  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] ?? '',
      employerId: map['employerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      salary: (map['salary'] ?? 0.0).toDouble(),
      jobType: map['jobType'] ?? 'Full-time',
      requirements: List<String>.from(map['requirements'] ?? []),
      skillsRequired: List<String>.from(map['skillsRequired'] ?? []),
      postedDate: (map['postedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      applicationDeadline: (map['applicationDeadline'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
      companyName: map['companyName'],
      companyLogo: map['companyLogo'],
      experienceLevel: map['experienceLevel'],
      category: map['category'],
    );
  }

  // Create a copy of JobModel with some fields updated
  JobModel copyWith({
    String? id,
    String? employerId,
    String? title,
    String? description,
    String? location,
    double? salary,
    String? jobType,
    List<String>? requirements,
    List<String>? skillsRequired,
    DateTime? postedDate,
    DateTime? applicationDeadline,
    bool? isActive,
    String? companyName,
    String? companyLogo,
    String? experienceLevel,
    String? category,
  }) {
    return JobModel(
      id: id ?? this.id,
      employerId: employerId ?? this.employerId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      jobType: jobType ?? this.jobType,
      requirements: requirements ?? this.requirements,
      skillsRequired: skillsRequired ?? this.skillsRequired,
      postedDate: postedDate ?? this.postedDate,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      isActive: isActive ?? this.isActive,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      category: category ?? this.category,
    );
  }
}
