import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/controllers/auth_controller.dart';
import 'package:job_portal_app/controllers/job_controller.dart';
import 'package:job_portal_app/screens/employer/add_job_screen.dart';

class JobPostsScreen extends StatefulWidget {
  const JobPostsScreen({Key? key}) : super(key: key);

  @override
  _JobPostsScreenState createState() => _JobPostsScreenState();
}

class _JobPostsScreenState extends State<JobPostsScreen> {
  late final JobController _jobController;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _jobController = Get.find<JobController>();
    _authController = Get.find<AuthController>();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final user = _authController.user;
    if (user == null) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }
    await _jobController.getEmployerJobs(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Job Posts')),
      body: Obx(() {
        if (_jobController.isLoading.value &&
            _jobController.employerJobs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_jobController.employerJobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No job posts yet', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => const AddJobScreen());
                  },
                  child: const Text('Post Your First Job'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _jobController.employerJobs.length,
          itemBuilder: (context, index) {
            final job = _jobController.employerJobs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(
                  job.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      job.description.length > 100
                          ? '${job.description.substring(0, 100)}...'
                          : job.description,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusChip(job.isActive),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(job.jobType),
                          backgroundColor: Colors.blue[50],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${job.salary.toStringAsFixed(0)}/year',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (job.applicationDeadline != null)
                      Text(
                        'Deadline: ${DateFormat('MMM d, y').format(job.applicationDeadline!)}',
                        style: TextStyle(
                          color:
                              job.applicationDeadline!.isBefore(DateTime.now())
                              ? Colors.red
                              : null,
                        ),
                      ),
                  ],
                ),
                isThreeLine: true,
                onTap: () {
                  Get.to(() => AddJobScreen(job: job));
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddJobScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Chip(
      label: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(color: isActive ? Colors.green[800] : Colors.red[800]),
      ),
      backgroundColor: isActive ? Colors.green[100] : Colors.red[100],
    );
  }
}
