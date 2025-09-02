import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  pending,
  reviewing,
  shortlisted,
  accepted,
  rejected,
}

class ApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String userId;
  final String? employerId;
  final DateTime appliedDate;
  final DateTime? statusUpdatedDate;
  final ApplicationStatus status;
  final String? rejectionReason;
  final String? interviewDate;
  final String? interviewLocation;
  final String? notes;
  final String? applicantName;
  final String? applicantEmail;
  final String? applicantPhone;
  final String? coverLetter;
  final String? resumeUrl;

  ApplicationModel({
    this.id = '',
    required this.jobId,
    required this.jobTitle,
    required this.userId,
    this.employerId,
    DateTime? appliedDate,
    this.status = ApplicationStatus.pending,
    this.statusUpdatedDate,
    this.rejectionReason,
    this.interviewDate,
    this.interviewLocation,
    this.notes,
    this.applicantName,
    this.applicantEmail,
    this.applicantPhone,
    this.coverLetter,
    this.resumeUrl,
  }) : appliedDate = appliedDate ?? DateTime.now();

  factory ApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return ApplicationModel(
      id: id,
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      userId: map['userId'] ?? '',
      employerId: map['employerId'],
      appliedDate: map['appliedDate'] != null 
          ? (map['appliedDate'] as Timestamp).toDate() 
          : null,
      status: _statusFromString(map['status'] ?? 'pending'),
      statusUpdatedDate: map['statusUpdatedDate'] != null 
          ? (map['statusUpdatedDate'] as Timestamp).toDate() 
          : null,
      rejectionReason: map['rejectionReason'],
      interviewDate: map['interviewDate'],
      interviewLocation: map['interviewLocation'],
      notes: map['notes'],
      applicantName: map['applicantName'],
      applicantEmail: map['applicantEmail'],
      applicantPhone: map['applicantPhone'],
      coverLetter: map['coverLetter'],
      resumeUrl: map['resumeUrl'],
    );
  }

  static ApplicationStatus _statusFromString(String status) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status.toLowerCase(),
      orElse: () => ApplicationStatus.pending,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'userId': userId,
      if (employerId != null) 'employerId': employerId,
      'appliedDate': Timestamp.fromDate(appliedDate),
      'status': status.toString().split('.').last,
      if (statusUpdatedDate != null) 'statusUpdatedDate': Timestamp.fromDate(statusUpdatedDate!),
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (interviewDate != null) 'interviewDate': interviewDate,
      if (interviewLocation != null) 'interviewLocation': interviewLocation,
      if (notes != null) 'notes': notes,
      if (applicantName != null) 'applicantName': applicantName,
      if (applicantEmail != null) 'applicantEmail': applicantEmail,
      if (applicantPhone != null) 'applicantPhone': applicantPhone,
      if (coverLetter != null) 'coverLetter': coverLetter,
      if (resumeUrl != null) 'resumeUrl': resumeUrl,
    };
  }

  ApplicationModel copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? userId,
    String? employerId,
    DateTime? appliedDate,
    ApplicationStatus? status,
    DateTime? statusUpdatedDate,
    String? rejectionReason,
    String? interviewDate,
    String? interviewLocation,
    String? notes,
    String? applicantName,
    String? applicantEmail,
    String? applicantPhone,
    String? coverLetter,
    String? resumeUrl,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      userId: userId ?? this.userId,
      employerId: employerId ?? this.employerId,
      appliedDate: appliedDate ?? this.appliedDate,
      status: status ?? this.status,
      statusUpdatedDate: statusUpdatedDate ?? this.statusUpdatedDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      interviewDate: interviewDate ?? this.interviewDate,
      interviewLocation: interviewLocation ?? this.interviewLocation,
      notes: notes ?? this.notes,
      applicantName: applicantName ?? this.applicantName,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      applicantPhone: applicantPhone ?? this.applicantPhone,
      coverLetter: coverLetter ?? this.coverLetter,
      resumeUrl: resumeUrl ?? this.resumeUrl,
    );
  }

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
