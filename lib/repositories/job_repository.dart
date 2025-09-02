import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/application_model.dart';

class JobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Job Posting Methods
  
  // Create a new job posting
  Future<JobModel> createJob(JobModel job) async {
    final docRef = await _firestore.collection('jobs').add(job.toMap());
    return job.copyWith(id: docRef.id);
  }

  // Update an existing job
  Future<void> updateJob(JobModel job) async {
    await _firestore.collection('jobs').doc(job.id).update(job.toMap());
  }

  // Delete a job
  Future<void> deleteJob(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).delete();
  }

  // Get job by ID
  Future<JobModel?> getJobById(String jobId) async {
    try {
      final doc = await _firestore.collection('jobs').doc(jobId).get();
      if (!doc.exists) return null;
      
      final data = doc.data();
      if (data == null) return null;
      
      return JobModel.fromMap(Map<String, dynamic>.from(data)..['id'] = doc.id);
    } catch (e) {
      print('Error getting job by ID: $e');
      return null;
    }
  }

  // Get all jobs with optional filters
  Stream<List<JobModel>> getJobs({
    String? employerId,
    bool? isActive,
    String? jobType,
    String? location,
    String? category,
    String? experienceLevel,
    double? minSalary,
  }) {
    Query query = _firestore.collection('jobs');

    if (employerId != null) {
      query = query.where('employerId', isEqualTo: employerId);
    }
    
    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }
    
    if (jobType != null && jobType.isNotEmpty) {
      query = query.where('jobType', isEqualTo: jobType);
    }
    
    if (location != null && location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    if (experienceLevel != null && experienceLevel.isNotEmpty) {
      query = query.where('experienceLevel', isEqualTo: experienceLevel);
    }
    
    if (minSalary != null) {
      query = query.where('salary', isGreaterThanOrEqualTo: minSalary);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) return null;
            return JobModel.fromMap(Map<String, dynamic>.from(data)..['id'] = doc.id);
          })
          .whereType<JobModel>()
          .toList();
    });
  }

  // Search jobs by title or description
  Stream<List<JobModel>> searchJobs(String searchTerm) {
    if (searchTerm.isEmpty) {
      return const Stream.empty();
    }

    final searchLower = searchTerm.toLowerCase();
    
    return _firestore
        .collection('jobs')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) return null;
            return JobModel.fromMap(Map<String, dynamic>.from(data)..['id'] = doc.id);
          })
          .whereType<JobModel>()
          .where((job) =>
              job.title.toLowerCase().contains(searchLower) ||
              job.description.toLowerCase().contains(searchLower))
          .toList();
    });
  }

  // Application Methods

  // Apply for a job
  Future<void> applyForJob(JobApplication application) async {
    await _firestore
        .collection('applications')
        .doc(application.id.isEmpty ? null : application.id)
        .set(application.toMap());
  }

  // Get applications by job seeker
  Stream<List<JobApplication>> getApplicationsByJobSeeker(String jobSeekerId) {
    return _firestore
        .collection('applications')
        .where('jobSeekerId', isEqualTo: jobSeekerId)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                JobApplication.fromMap(doc.data()..['id'] = doc.id))
            .toList());
  }

  // Get applications for a job (for employers)
  Stream<List<JobApplication>> getApplicationsByJob(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                JobApplication.fromMap(doc.data()..['id'] = doc.id))
            .toList());
  }

  // Update application status
  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
    String? rejectionReason,
    String? interviewDate,
    String? interviewLocation,
  }) async {
    final updateData = <String, dynamic>{
      'status': status.toString().split('.').last,
      'statusUpdatedDate': FieldValue.serverTimestamp(),
    };

    if (rejectionReason != null) {
      updateData['rejectionReason'] = rejectionReason;
    }
    
    if (interviewDate != null) {
      updateData['interviewDate'] = interviewDate;
    }
    
    if (interviewLocation != null) {
      updateData['interviewLocation'] = interviewLocation;
    }

    await _firestore
        .collection('applications')
        .doc(applicationId)
        .update(updateData);
  }

  // Get saved jobs for a user
  Stream<List<JobModel>> getSavedJobs(List<String> jobIds) {
    if (jobIds.isEmpty) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('jobs')
        .where(FieldPath.documentId, whereIn: jobIds)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.data()..['id'] = doc.id))
            .toList());
  }

  // Toggle save job for a user
  Future<void> toggleSaveJob({
    required String userId,
    required String jobId,
    required bool isSaved,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    if (isSaved) {
      await userRef.update({
        'savedJobs': FieldValue.arrayRemove([jobId])
      });
    } else {
      await userRef.update({
        'savedJobs': FieldValue.arrayUnion([jobId])
      });
    }
  }
}
