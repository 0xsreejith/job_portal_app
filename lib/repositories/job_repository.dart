import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/job_model.dart';
import '../models/application_model.dart';

class JobRepository extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -------------------- JOB METHODS --------------------

  Future<JobModel> createJob(JobModel job) async {
    final docRef = await _firestore.collection('jobs').add(job.toMap());
    return job.copyWith(id: docRef.id);
  }

  Future<void> updateJob(JobModel job) async {
    await _firestore.collection('jobs').doc(job.id).update(job.toMap());
  }

  Future<void> deleteJob(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).delete();
  }

  Future<JobModel?> getJobById(String jobId) async {
    try {
      final doc = await _firestore.collection('jobs').doc(jobId).get();
      if (!doc.exists) return null;
      return JobModel.fromMap(Map<String, dynamic>.from(doc.data()!)..['id'] = doc.id);
    } catch (e) {
      print('Error getting job by ID: $e');
      return null;
    }
  }

  Stream<List<JobModel>> getAllJobs() {
    return _firestore
        .collection('jobs')
        .where('isActive', isEqualTo: true)
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(Map<String, dynamic>.from(doc.data())..['id'] = doc.id))
            .toList());
  }

  Stream<List<JobModel>> getJobsByEmployer(String employerId) {
    return _firestore
        .collection('jobs')
        .where('employerId', isEqualTo: employerId)
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(Map<String, dynamic>.from(doc.data())..['id'] = doc.id))
            .toList());
  }

  // -------------------- APPLICATION METHODS --------------------

  Future<ApplicationModel> createApplication(ApplicationModel application) async {
    try {
      final docRef = await _firestore.collection('applications').add(application.toMap());
      return application.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating application: $e');
      rethrow;
    }
  }

  Stream<List<ApplicationModel>> getApplicationsForJob(String jobId) {
    try {
      return _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .orderBy('appliedDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ApplicationModel.fromMap(
                    Map<String, dynamic>.from(doc.data()),
                    doc.id,
                  ))
              .toList());
    } catch (e) {
      print('Error getting applications for job: $e');
      return const Stream.empty();
    }
  }

  Stream<List<ApplicationModel>> getApplicationsForEmployer(String employerId) {
    try {
      return _firestore
          .collection('applications')
          .where('employerId', isEqualTo: employerId)
          .orderBy('appliedDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ApplicationModel.fromMap(
                    Map<String, dynamic>.from(doc.data()),
                    doc.id,
                  ))
              .toList());
    } catch (e) {
      print('Error getting applications for employer: $e');
      return const Stream.empty();
    }
  }

  Future<ApplicationModel?> getApplicationById(String applicationId) async {
    try {
      final doc = await _firestore.collection('applications').doc(applicationId).get();
      if (!doc.exists) return null;
      return ApplicationModel.fromMap(Map<String, dynamic>.from(doc.data()!), doc.id);
    } catch (e) {
      print('Error getting application by ID: $e');
      return null;
    }
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
    String? rejectionReason,
    String? interviewDate,
    String? interviewLocation,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.toString().split('.').last,
        'statusUpdatedDate': FieldValue.serverTimestamp(),
      };

      if (status == ApplicationStatus.rejected) {
        updateData['rejectionReason'] = rejectionReason ?? 'No reason provided';
      } else {
        updateData['rejectionReason'] = null;
      }

      if (interviewDate != null) {
        updateData['interviewDate'] = interviewDate;
      }

      if (interviewLocation != null) {
        updateData['interviewLocation'] = interviewLocation;
      }

      await _firestore.collection('applications').doc(applicationId).update(updateData);
    } catch (e) {
      print('Error updating application status: $e');
      rethrow;
    }
  }

  Stream<List<ApplicationModel>> getApplicationsByUser(String userId) {
    try {
      return _firestore
          .collection('applications')
          .where('userId', isEqualTo: userId)
          .orderBy('appliedDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ApplicationModel.fromMap(
                    Map<String, dynamic>.from(doc.data()),
                    doc.id,
                  ))
              .toList());
    } catch (e) {
      print('Error getting applications by user: $e');
      return const Stream.empty();
    }
  }

  // -------------------- SAVED JOBS METHODS --------------------

  // Renamed to match controller
  Future<void> saveJobForUser(String userId, String jobId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_jobs')
        .doc(jobId)
        .set({'savedAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeSavedJob(String userId, String jobId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_jobs')
        .doc(jobId)
        .delete();
  }

  Stream<List<JobModel>> getSavedJobsForUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_jobs')
        .snapshots()
        .asyncMap((snapshot) async {
      final jobIds = snapshot.docs.map((doc) => doc.id).toList();
      if (jobIds.isEmpty) return [];
      final jobsSnapshot = await _firestore
          .collection('jobs')
          .where(FieldPath.documentId, whereIn: jobIds)
          .get();
      return jobsSnapshot.docs
          .map((doc) => JobModel.fromMap(Map<String, dynamic>.from(doc.data())..['id'] = doc.id))
          .toList();
    });
  }

  // -------------------- HELPER: Get Applicants with User Data --------------------

  Future<List<Map<String, dynamic>>> getApplicantsWithUserData(String jobId) async {
    final appsSnapshot = await _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('appliedDate', descending: true)
        .get();

    List<Map<String, dynamic>> applicants = [];

    for (var doc in appsSnapshot.docs) {
      final app = ApplicationModel.fromMap(doc.data(), doc.id);
      final userDoc = await _firestore.collection('users').doc(app.userId).get();
      if (userDoc.exists) {
        applicants.add({
          'application': app,
          'user': userDoc.data(),
        });
      }
    }

    return applicants;
  }
}
