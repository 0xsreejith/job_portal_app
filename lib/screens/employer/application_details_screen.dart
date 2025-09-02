import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_portal_app/models/application_model.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/repositories/job_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  final ApplicationModel application;
  final JobModel job;
  final JobRepository _jobRepo = Get.find();

  ApplicationDetailsScreen({
    Key? key,
    required this.application,
    required this.job,
  }) : super(key: key);

  Future<void> _updateApplicationStatus(ApplicationStatus status) async {
    try {
      await _jobRepo.updateApplicationStatus(
        applicationId: application.id,
        status: status,
      );
      Get.back(); // Close any open dialogs
      Get.snackbar(
        'Success',
        'Application status updated to ${status.toString().split('.').last}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update application status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      Get.snackbar('Error', 'Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          PopupMenuButton<ApplicationStatus>(
            onSelected: _updateApplicationStatus,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<ApplicationStatus>>[
              const PopupMenuItem<ApplicationStatus>(
                value: ApplicationStatus.pending,
                child: Text('Mark as Pending'),
              ),
              const PopupMenuItem<ApplicationStatus>(
                value: ApplicationStatus.accepted,
                child: Text('Accept Application'),
              ),
              const PopupMenuItem<ApplicationStatus>(
                value: ApplicationStatus.rejected,
                child: Text('Reject Application'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Applicant Information'),
            _buildInfoRow('Name', application.applicantName ?? 'Not provided'),
            _buildInfoRow('Email', application.applicantEmail ?? 'Not provided'),
            _buildInfoRow('Phone', application.applicantPhone ?? 'Not provided'),
            _buildInfoRow('Applied on', application.appliedDate.toLocal().toString().split('.')[0]),
            const SizedBox(height: 16),
            
            _buildSectionTitle('Cover Letter'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                application.coverLetter ?? 'No cover letter provided',
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            
            if (application.resumeUrl != null) ...[
              _buildSectionTitle('Resume'),
              ElevatedButton.icon(
                onPressed: () => _launchURL(application.resumeUrl!),
                icon: const Icon(Icons.file_download),
                label: const Text('View Resume'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            _buildSectionTitle('Job Details'),
            _buildInfoRow('Position', job.title),
            _buildInfoRow('Location', job.location),
            _buildInfoRow('Job Type', job.jobType),
            _buildInfoRow('Salary', '\$${job.salary.toStringAsFixed(2)}'),
            
            const SizedBox(height: 24),
            _buildStatusChip(application.statusString),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'under review':
        chipColor = Colors.blue;
        break;
      case 'shortlisted':
        chipColor = Colors.lightBlue;
        break;
      case 'accepted':
        chipColor = Colors.green;
        break;
      case 'rejected':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
