import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/job_controller.dart';
import '../../models/category_model.dart';
import '../../models/job_model.dart';
import '../../screens/profile_screen.dart';
import '../../screens/saved_jobs_screen.dart';
import '../../widgets/shared/category_chip.dart';
import '../../widgets/shared/job_card.dart';

// Tab navigation enum
enum _SeekerTab { home, saved, profile }

class SeekerHomeScreen extends StatefulWidget {
  const SeekerHomeScreen({Key? key}) : super(key: key);

  @override
  _SeekerHomeScreenState createState() => _SeekerHomeScreenState();
}

class _SeekerHomeScreenState extends State<SeekerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final JobController _jobController = Get.find<JobController>();
  int _selectedCategoryIndex = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  // Load jobs from the controller
  void _loadJobs() {
    _jobController.loadAllJobs();
    ever(_jobController.isLoading, (isLoading) {
      if (!isLoading) {
        _updateCategoryCounts();
      }
    });
  }

  // Categories
  final List<Map<String, dynamic>> _categories = [
    {'id': '1', 'name': 'All', 'icon': 'work', 'jobCount': 0},
    {'id': '2', 'name': 'Development', 'icon': 'code', 'jobCount': 0},
    {'id': '3', 'name': 'Design', 'icon': 'design', 'jobCount': 0},
    {'id': '4', 'name': 'Marketing', 'icon': 'business', 'jobCount': 0},
    {'id': '5', 'name': 'Finance', 'icon': 'attach_money', 'jobCount': 0},
  ];

  // Filter jobs
  List<JobModel> get _filteredJobs {
    var jobs = _jobController.allJobs;

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      jobs = jobs.where((job) {
        return job.title.toLowerCase().contains(searchQuery) ||
            (job.companyName?.toLowerCase().contains(searchQuery) ?? false) ||
            job.location.toLowerCase().contains(searchQuery);
      }).toList();
    }

    final selectedCategory = _categories[_selectedCategoryIndex]['name'];
    if (selectedCategory != 'All') {
      jobs = jobs.where((job) => job.category == selectedCategory).toList();
    }

    return jobs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateCategoryCounts() {
    final jobs = _jobController.allJobs;
    for (var i = 0; i < _categories.length; i++) {
      if (_categories[i]['name'] == 'All') {
        _categories[i]['jobCount'] = jobs.length;
      } else {
        _categories[i]['jobCount'] =
            jobs.where((job) => job.category == _categories[i]['name']).length;
      }
    }
    if (mounted) setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildCurrentScreen() {
    switch (_SeekerTab.values[_currentIndex]) {
      case _SeekerTab.home:
        return _buildHomeScreen();
      case _SeekerTab.saved:
        return const SavedJobsScreen();
      case _SeekerTab.profile:
        return const ProfileScreen();
    }
  }

  Widget _buildHomeScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        final isDesktop = constraints.maxWidth >= 1024;

        return Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search jobs...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            // Categories
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = CategoryModel.fromMap(_categories[index]);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CategoryChip(
                      category: category,
                      isSelected: _selectedCategoryIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Job list
            Expanded(
              child: Obx(() {
                if (_jobController.isLoading.value &&
                    _jobController.allJobs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final jobs = _filteredJobs;

                if (jobs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No jobs found. Try adjusting your search or filters.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // Responsive grid/list
                if (isDesktop) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 4 / 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return JobCard(
                        job: job,
                        onTap: () {
                          Get.toNamed('/job_details', arguments: job.id);
                        },
                      );
                    },
                  );
                } else if (isTablet) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 4 / 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return JobCard(
                        job: job,
                        onTap: () {
                          Get.toNamed('/job_details', arguments: job.id);
                        },
                      );
                    },
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: JobCard(
                          job: job,
                          onTap: () {
                            Get.toNamed('/job_details', arguments: job.id);
                          },
                        ),
                      );
                    },
                  );
                }
              }),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Get.snackbar('Notifications', 'No new notifications');
            },
          ),
        ],
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
