import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_portal_app/models/application_model.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  final ApplicationModel application;

  const ApplicationDetailsScreen({Key? key, required this.application})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Applicant Info'),
            _buildInfoRow('Name', application.jobTitle),
            _buildInfoRow('Email', application.applicantEmail ?? 'N/A'),
            _buildInfoRow('Phone', application.applicantPhone ?? 'N/A'),
            const SizedBox(height: 16),

            _buildSectionTitle('Job Info'),
            _buildInfoRow('Job Title', application.jobTitle),
            _buildInfoRow('Job ID', application.jobId),
            _buildInfoRow(
                'Applied Date', _formatDate(application.appliedDate)),
            const SizedBox(height: 16),

            _buildSectionTitle('Application Status'),
            _buildInfoRow('Status', application.status.name),
            _buildInfoRow(
                'Status Updated',
                application.statusUpdatedDate != null
                    ? _formatDate(application.statusUpdatedDate!)
                    : 'N/A'),
            if (application.rejectionReason != null)
              _buildInfoRow('Rejection Reason', application.rejectionReason!),
            const SizedBox(height: 16),

            _buildSectionTitle('Additional Info'),
            _buildInfoRow('Cover Letter', application.coverLetter ?? 'N/A'),
            _buildInfoRow('Notes', application.notes ?? 'N/A'),
            _buildInfoRow('Interview Date', application.interviewDate ?? 'N/A'),
            _buildInfoRow(
                'Interview Location', application.interviewLocation ?? 'N/A'),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // You can add logic to update status here if needed
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
