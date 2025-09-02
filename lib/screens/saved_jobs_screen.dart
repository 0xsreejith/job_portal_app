import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/job_controller.dart';
import 'job_details_screen.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({Key? key}) : super(key: key);

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final JobController _jobController = Get.find<JobController>();
  
  @override
  void initState() {
    super.initState();
    _loadSavedJobs();
  }

  Future<void> _loadSavedJobs() async {
    final user = _authController.user;
    if (user != null) {
      _jobController.loadSavedJobs(user.id);
    }
    return; // Return a completed future
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_jobController.isLoading.value && _jobController.savedJobs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final savedJobs = _jobController.savedJobs;

        if (savedJobs.isEmpty) {
          return const Center(
            child: Text(
              'No saved jobs yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

          return RefreshIndicator(
            onRefresh: _loadSavedJobs,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: savedJobs.length,
              itemBuilder: (context, index) {
                final job = savedJobs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        if (job.companyName != null)
                          Text(
                            job.companyName!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          job.location,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(job.jobType),
                              backgroundColor: Colors.blue[50],
                              labelStyle: const TextStyle(color: Colors.blue),
                            ),
                            const SizedBox(width: 8),
                            if (job.salary > 0)
                              Text(
                                '\$${job.salary.toStringAsFixed(0)}/year',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.to(() => JobDetailsScreen(job: job));
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark, color: Colors.blue),
                      onPressed: () => _unsaveJob(job.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _unsaveJob(String jobId) async {
    try {
      final user = _authController.user;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }
      
      await _jobController.toggleSaveJob(jobId, user.id);
      Get.snackbar('Success', 'Job removed from saved jobs');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove job: $e');
    }
  }
}
