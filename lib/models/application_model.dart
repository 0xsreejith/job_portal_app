import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  pending,
  reviewing,
  shortlisted,
  accepted,
  rejected,
}

class JobApplication {
  final String id;
  final String jobId;
  final String jobTitle;
  final String jobSeekerId;
  final String jobSeekerName;
  final String? resumeUrl;
  final String? coverLetter;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final DateTime? statusUpdatedDate;
  final String? employerId;
  final String? employerName;
  final String? rejectionReason;
  final String? interviewDate;
  final String? interviewLocation;
  final String? notes;

  JobApplication({
    this.id = '',
    required this.jobId,
    required this.jobTitle,
    required this.jobSeekerId,
    required this.jobSeekerName,
    this.resumeUrl,
    this.coverLetter,
    this.status = ApplicationStatus.pending,
    DateTime? appliedDate,
    this.statusUpdatedDate,
    this.employerId,
    this.employerName,
    this.rejectionReason,
    this.interviewDate,
    this.interviewLocation,
    this.notes,
  }) : appliedDate = appliedDate ?? DateTime.now();

  // Convert JobApplication to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'jobSeekerId': jobSeekerId,
      'jobSeekerName': jobSeekerName,
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'status': status.toString().split('.').last,
      'appliedDate': Timestamp.fromDate(appliedDate),
      'statusUpdatedDate': statusUpdatedDate != null
          ? Timestamp.fromDate(statusUpdatedDate!)
          : null,
      'employerId': employerId,
      'employerName': employerName,
      'rejectionReason': rejectionReason,
      'interviewDate': interviewDate,
      'interviewLocation': interviewLocation,
      'notes': notes,
    };
  }

  // Create JobApplication from a Map
  factory JobApplication.fromMap(Map<String, dynamic> map) {
    return JobApplication(
      id: map['id'] ?? '',
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      jobSeekerId: map['jobSeekerId'] ?? '',
      jobSeekerName: map['jobSeekerName'] ?? '',
      resumeUrl: map['resumeUrl'],
      coverLetter: map['coverLetter'],
      status: _parseApplicationStatus(map['status']),
      appliedDate: (map['appliedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      statusUpdatedDate: (map['statusUpdatedDate'] as Timestamp?)?.toDate(),
      employerId: map['employerId'],
      employerName: map['employerName'],
      rejectionReason: map['rejectionReason'],
      interviewDate: map['interviewDate'],
      interviewLocation: map['interviewLocation'],
      notes: map['notes'],
    );
  }

  // Helper method to parse ApplicationStatus from string
  static ApplicationStatus _parseApplicationStatus(String? status) {
    if (status == null) return ApplicationStatus.pending;
    
    return ApplicationStatus.values.firstWhere(
      (e) => e.toString() == 'ApplicationStatus.${status.toLowerCase()}',
      orElse: () => ApplicationStatus.pending,
    );
  }

  // Create a copy of JobApplication with some fields updated
  JobApplication copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? jobSeekerId,
    String? jobSeekerName,
    String? resumeUrl,
    String? coverLetter,
    ApplicationStatus? status,
    DateTime? appliedDate,
    DateTime? statusUpdatedDate,
    String? employerId,
    String? employerName,
    String? rejectionReason,
    String? interviewDate,
    String? interviewLocation,
    String? notes,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      jobSeekerId: jobSeekerId ?? this.jobSeekerId,
      jobSeekerName: jobSeekerName ?? this.jobSeekerName,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      statusUpdatedDate: statusUpdatedDate ?? this.statusUpdatedDate,
      employerId: employerId ?? this.employerId,
      employerName: employerName ?? this.employerName,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      interviewDate: interviewDate ?? this.interviewDate,
      interviewLocation: interviewLocation ?? this.interviewLocation,
      notes: notes ?? this.notes,
    );
  }

  // Get status as a display string
  String get statusString {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.reviewing:
        return 'Under Review';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }
}
