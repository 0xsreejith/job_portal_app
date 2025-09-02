import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_portal_app/controllers/auth_controller.dart';
import 'package:job_portal_app/controllers/job_controller.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/application_model.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobModel job;

  JobDetailsScreen({Key? key, required this.job}) : super(key: key);

  final AuthController _authController = Get.find<AuthController>();
  final JobController _jobController = Get.find<JobController>();

  @override
  Widget build(BuildContext context) {
    // Add a reactive set to track applied jobs
    final RxSet<String> appliedJobs = <String>{}.obs;

    // Check if already applied
    bool isApplied() => appliedJobs.contains(job.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
       actions: [
  Obx(() {
    return IconButton(
      icon: Icon(
        _jobController.isSavedJob(job.id)
            ? Icons.bookmark
            : Icons.bookmark_outline,
        color: Colors.blue,
      ),
      onPressed: () async {
        final user = _authController.user;
        if (user == null) {
          Get.snackbar('Error', 'User not authenticated');
          return;
        }
        await _jobController.toggleSaveJob(job.id, user.id);
      },
    );
  }),
],

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Info
            if (job.companyName != null)
              Row(
                children: [
                  if (job.companyLogo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        job.companyLogo!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      job.companyName!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Job Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(job.jobType),
                  backgroundColor: Colors.blue[50],
                  labelStyle: const TextStyle(color: Colors.blue),
                ),
                if (job.salary > 0)
                  Text(
                    '\$${job.salary.toStringAsFixed(0)}/year',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Experience & Category
            if (job.experienceLevel != null)
              Text('Experience: ${job.experienceLevel}'),
            if (job.category != null)
              Text('Category: ${job.category}'),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Job Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(job.description),
            const SizedBox(height: 16),

            // Requirements
            if (job.requirements.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Requirements',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...job.requirements.map(
                    (req) => Row(
                      children: [
                        const Icon(Icons.check, size: 16, color: Colors.blue),
                        const SizedBox(width: 6),
                        Expanded(child: Text(req)),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Skills
            if (job.skillsRequired.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skills Required',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: job.skillsRequired
                        .map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor: Colors.grey[200],
                            ))
                        .toList(),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Apply Button
            Center(
              child: Obx(() => ElevatedButton(
                    onPressed: _jobController.isLoading.value || isApplied()
                        ? null
                        : () async {
                            final user = _authController.user;
                            if (user == null) {
                              Get.snackbar(
                                  'Error', 'Please login to apply for jobs');
                              return;
                            }
                            try {
                              _jobController.isLoading.value = true;
                              
                              // Create a new application
                              final application = ApplicationModel(
                                jobId: job.id,
                                jobTitle: job.title,
                                userId: user.id,
                                employerId: job.employerId,
                                applicantName: user.displayName ?? 'Anonymous',
                                applicantEmail: user.email,
                                applicantPhone: user.phoneNumber,
                                status: ApplicationStatus.pending,
                                appliedDate: DateTime.now(),
                                resumeUrl: '', // You might want to get this from user profile
                                coverLetter: '', // You might want to add a field for this
                              );
                              
                              // Save the application
                              await _jobController.createApplication(application);
                              
                              appliedJobs.add(job.id); // Mark as applied
                            } catch (e) {
                              Get.snackbar('Error', 'Failed to apply: ${e.toString()}');
                              rethrow;
                            } finally {
                              _jobController.isLoading.value = false;
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _jobController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isApplied() ? 'Applied' : 'Apply Now',
                            style: const TextStyle(fontSize: 18),
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

