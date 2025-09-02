import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/job_model.dart';
import '../models/application_model.dart';
import '../repositories/job_repository.dart';

class JobController extends GetxController {
  final JobRepository _jobRepository = Get.find();

  // -------------------- OBSERVABLES --------------------
  final RxList<JobModel> employerJobs = <JobModel>[].obs;
  final RxList<JobModel> _savedJobs = <JobModel>[].obs;
  final RxList<JobModel> _allJobs = <JobModel>[].obs;
  final RxList<ApplicationModel> _applications = <ApplicationModel>[].obs;
  final RxBool isLoading = false.obs;

  // -------------------- GETTERS --------------------
  List<JobModel> get allJobs => _allJobs.toList();
  List<JobModel> get savedJobs => _savedJobs.toList();
  List<ApplicationModel> get applications => _applications.toList();

  // -------------------- STREAM SUBSCRIPTIONS --------------------
  StreamSubscription<List<JobModel>>? _jobsSubscription;
  StreamSubscription<List<JobModel>>? _savedJobsSubscription;
  StreamSubscription<List<JobModel>>? _employerJobsSubscription;
  StreamSubscription<List<ApplicationModel>>? _applicationsSubscription;

  // -------------------- JOB CRUD --------------------
  Future<void> createJob(JobModel job) async {
    try {
      isLoading.value = true;
      await _jobRepository.createJob(job);
      await getEmployerJobs(job.employerId);
    } catch (e) {
    // Get.snackbar('Error', 'Failed to post job: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getEmployerJobs(String employerId) async {
    try {
      isLoading.value = true;
      _employerJobsSubscription?.cancel();
      _employerJobsSubscription =
          _jobRepository.getJobsByEmployer(employerId).listen((jobs) {
        employerJobs.assignAll(jobs);
        isLoading.value = false;
      }, onError: (e) {
        debugPrint('Error fetching employer jobs: $e');
        isLoading.value = false;
      });
    } catch (e) {
      debugPrint('Exception in getEmployerJobs: $e');
      isLoading.value = false;
    }
  }

  Future<void> updateJob(JobModel job) async {
    try {
      isLoading.value = true;
      await _jobRepository.updateJob(job);
      await getEmployerJobs(job.employerId);
    } catch (e) {
  //    Get.snackbar('Error', 'Failed to update job: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteJob(String jobId, String employerId) async {
    try {
      isLoading.value = true;
      await _jobRepository.deleteJob(jobId);
      await getEmployerJobs(employerId);
    } catch (e) {
   //   Get.snackbar('Error', 'Failed to delete job: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------- SAVED JOBS --------------------
  void loadSavedJobs(String userId) {
    try {
      isLoading.value = true;
      _savedJobsSubscription?.cancel();
      _savedJobsSubscription =
          _jobRepository.getSavedJobsForUser(userId).listen((jobs) {
        _savedJobs.assignAll(jobs);
        isLoading.value = false;
      }, onError: (e) {
    //    Get.snackbar('Error', 'Failed to load saved jobs: $e');
        isLoading.value = false;
      });
    } catch (e) {
   ///   Get.snackbar('Error', 'Failed to load saved jobs: $e');
      isLoading.value = false;
    }
  }

  Future<void> toggleSaveJob(String jobId, String userId) async {
    try {
      isLoading.value = true;
      final isSaved = _savedJobs.any((job) => job.id == jobId);

      if (isSaved) {
        await _jobRepository.removeSavedJob(userId, jobId);
        _savedJobs.removeWhere((job) => job.id == jobId);
      } else {
        await _jobRepository.saveJobForUser(userId, jobId);
        final job = await _jobRepository.getJobById(jobId);
        if (job != null) {
          _savedJobs.add(job);
        }
      }
    } catch (e) {
    //  Get.snackbar('Error', 'Failed to update saved jobs: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------- APPLICATIONS --------------------
  void loadUserApplications(String userId) {
    try {
      isLoading.value = true;
      _applicationsSubscription?.cancel();
      _applicationsSubscription =
          _jobRepository.getApplicationsByUser(userId).listen((apps) {
        _applications.assignAll(apps);
        isLoading.value = false;
      }, onError: (e) {
    //    Get.snackbar('Error', 'Failed to load applications: $e');
        isLoading.value = false;
      });
    } catch (e) {
  //    Get.snackbar('Error', 'Failed to load applications: $e');
      isLoading.value = false;
    }
  }

  void loadEmployerApplications(String employerId) {
    try {
      isLoading.value = true;
      _applicationsSubscription?.cancel();
      _applicationsSubscription =
          _jobRepository.getApplicationsForEmployer(employerId).listen((apps) {
        _applications.assignAll(apps);
        isLoading.value = false;
      }, onError: (e) {
 //       Get.snackbar('Error', 'Failed to load applications: $e');
        isLoading.value = false;
      });
    } catch (e) {
 //     Get.snackbar('Error', 'Failed to load applications: $e');
      isLoading.value = false;
    }
  }

  // -------------------- ALL JOBS --------------------
  void loadAllJobs() {
    try {
      isLoading.value = true;
      _jobsSubscription?.cancel();
      _jobsSubscription = _jobRepository.getAllJobs().listen((jobs) {
        _allJobs.assignAll(jobs);
        isLoading.value = false;
      }, onError: (e) {
        debugPrint('Error loading jobs: $e');
        isLoading.value = false;
      });
    } catch (e) {
      debugPrint('Exception in loadAllJobs: $e');
    //  Get.snackbar('Error', 'Failed to load jobs: $e');
      isLoading.value = false;
    }
  }

  // -------------------- SEARCH & FILTER --------------------
  List<JobModel> searchJobs(String query) {
    if (query.isEmpty) return _allJobs.toList();

    final lowerQuery = query.toLowerCase();
    return _allJobs.where((job) {
      return job.title.toLowerCase().contains(lowerQuery) ||
          (job.companyName?.toLowerCase().contains(lowerQuery) ?? false) ||
          job.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<JobModel> getJobsByCategory(String category) {
    if (category == 'All') return _allJobs.toList();
    return _allJobs.where((job) => job.category == category).toList();
  }

  // -------------------- APPLICATION MANAGEMENT --------------------
  Future<void> createApplication(ApplicationModel application) async {
    try {
      isLoading.value = true;
      await _jobRepository.createApplication(application);
    } catch (e) {
  //    Get.snackbar('Error', 'Failed to submit application: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApplicationModel?> getApplicationById(String applicationId) async {
    try {
      isLoading.value = true;
      return await _jobRepository.getApplicationById(applicationId);
    } catch (e) {
  //    Get.snackbar('Error', 'Failed to load application: $e');
      return null;
    } finally {
      isLoading.value = false;
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
      isLoading.value = true;
      await _jobRepository.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
        rejectionReason: rejectionReason,
        interviewDate: interviewDate,
        interviewLocation: interviewLocation,
      );

      final index = _applications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        final updatedApp = _applications[index].copyWith(
          status: status,
          statusUpdatedDate: DateTime.now(),
          rejectionReason: rejectionReason,
          interviewDate: interviewDate,
          interviewLocation: interviewLocation,
        );
        _applications[index] = updatedApp;
        _applications.refresh();
      }
    } catch (e) {
  //    Get.snackbar('Error', 'Failed to update application status: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  bool isSavedJob(String jobId) {
    return _savedJobs.any((job) => job.id == jobId);
  }

  // -------------------- CLEANUP --------------------
  @override
  void onClose() {
    _jobsSubscription?.cancel();
    _savedJobsSubscription?.cancel();
    _applicationsSubscription?.cancel();
    _employerJobsSubscription?.cancel();
    super.onClose();
  }
}
