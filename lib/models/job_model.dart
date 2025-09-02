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

  // Helper method to safely convert dynamic list to List<String>
  static List<String> _parseStringList(dynamic list) {
    if (list == null) return [];
    if (list is List) {
      return list.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  // Helper method to safely parse DateTime from dynamic value
  static DateTime? _parseDateTime(dynamic value) {
    try {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value);
      return null;
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  // Create JobModel from a Map
  factory JobModel.fromMap(Map<String, dynamic> map) {
    try {
      if (map.isEmpty) throw ArgumentError('Empty map provided to JobModel.fromMap');
      
      // Parse required fields with null checks
      final id = map['id']?.toString() ?? '';
      final employerId = map['employerId']?.toString() ?? '';
      final title = map['title']?.toString() ?? '';
      final description = map['description']?.toString() ?? '';
      final location = map['location']?.toString() ?? '';
      
      // Parse salary with fallback to 0.0 if invalid
      double salary;
      try {
        salary = (map['salary'] is num) 
            ? (map['salary'] as num).toDouble() 
            : double.tryParse(map['salary']?.toString() ?? '0.0') ?? 0.0;
      } catch (e) {
        print('Error parsing salary: $e');
        salary = 0.0;
      }
      
      return JobModel(
        id: id,
        employerId: employerId,
        title: title,
        description: description,
        location: location,
        salary: salary,
        jobType: map['jobType']?.toString() ?? 'Full-time',
        requirements: _parseStringList(map['requirements']),
        skillsRequired: _parseStringList(map['skillsRequired']),
        postedDate: _parseDateTime(map['postedDate']) ?? DateTime.now(),
        applicationDeadline: _parseDateTime(map['applicationDeadline']),
        isActive: map['isActive'] == true,
        companyName: map['companyName']?.toString(),
        companyLogo: map['companyLogo']?.toString(),
        experienceLevel: map['experienceLevel']?.toString(),
        category: map['category']?.toString(),
      );
    } catch (e) {
      print('Error creating JobModel from map: $e');
      print('Map data: $map');
      rethrow; // Re-throw to allow error handling upstream
    }
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
