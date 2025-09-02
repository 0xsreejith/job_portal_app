import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_portal_app/controllers/auth_controller.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/application_model.dart';
import 'package:job_portal_app/repositories/job_repository.dart';
import 'package:job_portal_app/screens/employer/add_job_screen.dart';
import 'package:job_portal_app/screens/employer/application_details_screen.dart';
import 'package:job_portal_app/widgets/shared/job_card.dart';
import 'job_posts_screen.dart';

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({Key? key}) : super(key: key);

  @override
  _EmployerHomeScreenState createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final JobRepository _jobRepository = Get.find();
  final AuthController _authController = Get.find();

  final RxList<JobModel> _postedJobs = <JobModel>[].obs;
  final RxList<ApplicationModel> _recentApplications = <ApplicationModel>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _isLoading.value = true;

      // 1. Load posted jobs
      _jobRepository.getJobsByEmployer(_authController.user!.id).listen((jobs) {
  _postedJobs.assignAll(jobs);
});


      // 2. Listen to all applications for this employer
      _jobRepository.getApplicationsForEmployer(_authController.user!.id).listen(
        (apps) {
          _recentApplications.assignAll(apps);
        },
        onError: (error) {
          Get.snackbar('Error', 'Failed to load applications: $error');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.work_outline),
            onPressed: () {
              Get.to(() => JobPostsScreen());
            },
            tooltip: 'Manage Job Posts',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _authController.signOut,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Posted Jobs'),
            Tab(text: 'Applications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostedJobsTab(),
          _buildApplicationsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddJobScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostedJobsTab() {
    return Obx(() {
      if (_isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_postedJobs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No jobs posted yet'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => AddJobScreen());
                },
                child: const Text('Post a Job'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _postedJobs.length,
        itemBuilder: (context, index) {
          final job = _postedJobs[index];
          return JobCard(
            job: job,
            onTap: () {
              // Navigate to job details if needed
            },
          );
        },
      );
    });
  }

  Widget _buildApplicationsTab() {
    return Obx(() {
      if (_isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_recentApplications.isEmpty) {
        return const Center(child: Text('No applications yet'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _recentApplications.length,
        itemBuilder: (context, index) {
          final application = _recentApplications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
             
              title: Text(application.applicantName ?? 'N/A'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(application.jobTitle),
                  const SizedBox(height: 4),
                  Text(
                    'Applied: ${_formatDate(application.appliedDate  ?? DateTime.now())}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: PopupMenuButton<ApplicationStatus>(
                onSelected: (status) =>
                    _updateApplicationStatus(application, status),
                itemBuilder: (context) => ApplicationStatus.values
                    .map(
                      (status) => PopupMenuItem(
                        value: status,
                        child: Text(status.name),
                      ),
                    )
                    .toList(),
              ),
              onTap: () {
                // Navigate to application details
                    Get.to(() => ApplicationDetailsScreen(
                      application: application,
                      job: _postedJobs.firstWhere((j) => j.id == application.jobId),
                    )); 
              },
            ),
          );
        },
      );
    });
  }

  Future<void> _updateApplicationStatus(
      ApplicationModel application, ApplicationStatus newStatus) async {
    try {
      await _jobRepository.updateApplicationStatus(
        applicationId: application.id,
        status: newStatus,
      );

      // Update local state
      final index =
          _recentApplications.indexWhere((app) => app.id == application.id);
      if (index != -1) {
        _recentApplications[index] = application.copyWith(
          status: newStatus,
          statusUpdatedDate: DateTime.now(),
        );
      }

      Get.snackbar('Success', 'Application status updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update application status: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
