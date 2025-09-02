import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_portal_app/models/application_model.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/repositories/job_repository.dart';
import 'package:job_portal_app/screens/employer/application_details_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  final JobModel job;

  const ApplicationsScreen({Key? key, required this.job}) : super(key: key);

  @override
  _ApplicationsScreenState createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final JobRepository _jobRepo = Get.find();
  late Stream<List<ApplicationModel>> _applicationsStream;

  @override
  void initState() {
    super.initState();
    _applicationsStream = _jobRepo.getApplicationsForJob(widget.job.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Applications for ${widget.job.title}'),
      ),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: _applicationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final applications = snapshot.data ?? [];

          if (applications.isEmpty) {
            return const Center(child: Text('No applications yet.'));
          }

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(application.jobTitle),
                  subtitle: Text(application.status.toString().toUpperCase()),
                  trailing: _buildStatusChip(application.status.toString()),
                  onTap: () {
                    Get.to(
                      () => ApplicationDetailsScreen(
                        application: application,
                        job: widget.job,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'accepted':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
