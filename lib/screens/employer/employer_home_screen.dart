import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../models/application_model.dart';
import '../../widgets/shared/job_card.dart';
import '../../widgets/shared/search_bar.dart';

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({Key? key}) : super(key: key);

  @override
  _EmployerHomeScreenState createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Sample data - Replace with actual data from your backend
  final List<JobModel> _postedJobs = [
    JobModel(
      id: '1',
      employerId: 'emp1',
      title: 'Senior Flutter Developer',
      description: 'We are looking for an experienced Flutter developer...',
      location: 'Remote',
      salary: 8000,
      jobType: 'Full-time',
      requirements: ['3+ years of Flutter', 'Strong Dart skills'],
      skillsRequired: ['Flutter', 'Dart', 'Firebase'],
      companyName: 'TechCorp',
      category: 'Development',
    ),
  ];

  final List<JobApplication> _recentApplications = [
    JobApplication(
      id: 'app1',
      jobId: '1',
      jobTitle: 'Senior Flutter Developer',
      jobSeekerId: 'js1',
      jobSeekerName: 'John Doe',
      status: ApplicationStatus.reviewing,
      appliedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToPostJob,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Applicants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildPostedJobs();
      case 2:
        return _buildApplicants();
      case 3:
        return _buildProfile();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s what\'s happening with your job postings',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick Stats
          const Text(
            'Quick Stats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Active Jobs',
                '5',
                Icons.work_outline,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Applications',
                '24',
                Icons.assignment_outlined,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recent Applications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Applications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _currentIndex = 2);
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRecentApplications(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentApplications() {
    if (_recentApplications.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No recent applications'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentApplications.length,
      itemBuilder: (context, index) {
        final application = _recentApplications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              child: Text(application.jobSeekerName[0]),
            ),
            title: Text(application.jobSeekerName),
            subtitle: Text(application.jobTitle),
            trailing: Chip(
              label: Text(
                application.status.toString().split('.').last,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: _getStatusColor(application.status),
            ),
            onTap: () {
              // Navigate to application details
            },
          ),
        );
      },
    );
  }

  Widget _buildPostedJobs() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomSearchBar(
            controller: _searchController,
            hintText: 'Search your job postings...',
            onChanged: (value) {
              // Handle search
            },
          ),
        ),
        Expanded(
          child: _postedJobs.isEmpty
              ? const Center(child: Text('No jobs posted yet'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _postedJobs.length,
                  itemBuilder: (context, index) {
                    final job = _postedJobs[index];
                    return JobCard(
                      job: job,
                      onTap: () {
                        // Navigate to job details
                      },
                      showSaveButton: false,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildApplicants() {
    return _recentApplications.isEmpty
        ? const Center(child: Text('No applications yet'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _recentApplications.length,
            itemBuilder: (context, index) {
              final app = _recentApplications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    child: Text(app.jobSeekerName[0]),
                  ),
                  title: Text(app.jobSeekerName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.jobTitle),
                      const SizedBox(height: 4),
                      Text(
                        'Applied: ${_formatDate(app.appliedDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<ApplicationStatus>(
                    onSelected: (status) {
                      void _updateApplicationStatus(JobApplication app, ApplicationStatus newStatus) {
                        // In a real app, you would update this in Firestore
                        setState(() {
                          // Create a new instance with updated status since status is final
                          final updatedApp = JobApplication(
                            id: app.id,
                            jobId: app.jobId,
                            jobTitle: app.jobTitle,
                            jobSeekerId: app.jobSeekerId,
                            jobSeekerName: app.jobSeekerName,
                            resumeUrl: app.resumeUrl,
                            coverLetter: app.coverLetter,
                            status: newStatus, // This is where we set the new status
                            appliedDate: app.appliedDate,
                            statusUpdatedDate: DateTime.now(),
                            employerId: app.employerId,
                            employerName: app.employerName,
                            rejectionReason: app.rejectionReason,
                            interviewDate: app.interviewDate,
                            interviewLocation: app.interviewLocation,
                            notes: app.notes,
                          );
                          
                          // Find and replace the application in the list
                          final index = _recentApplications.indexWhere((a) => a.id == app.id);
                          if (index != -1) {
                            _recentApplications[index] = updatedApp;
                          }
                        });
                      }
                      _updateApplicationStatus(app, status);
                    },
                    itemBuilder: (context) => ApplicationStatus.values
                        .map((status) => PopupMenuItem(
                              value: status,
                              child: Text(
                                status.toString().split('.').last,
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                ),
                              ),
                            ))
                        .toList(),
                    child: Chip(
                      label: Text(
                        app.status.toString().split('.').last,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: _getStatusColor(app.status),
                    ),
                  ),
                  onTap: () {
                    // Navigate to application details
                  },
                ),
              );
            },
          );
  }

  Widget _buildProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.business, size: 50),
          ),
          const SizedBox(height: 16),
          const Text(
            'Company Name',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'company@example.com',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to help
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Colors.orange[100]!;
      case ApplicationStatus.reviewing:
        return Colors.blue[100]!;
      case ApplicationStatus.shortlisted:
        return Colors.purple[100]!;
      case ApplicationStatus.accepted:
        return Colors.green[100]!;
      case ApplicationStatus.rejected:
        return Colors.red[100]!;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToPostJob() {
    // Navigate to post job screen
    // Get.to(() => const PostJobScreen());
  }

  void _signOut() {
    // Sign out logic
    // Get.find<AuthController>().signOut();
  }
}
