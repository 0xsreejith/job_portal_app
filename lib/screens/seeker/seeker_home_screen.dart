import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/category_model.dart';
import '../../models/job_model.dart';
import '../../widgets/shared/category_chip.dart';
import '../../widgets/shared/job_card.dart';
import '../../widgets/shared/search_bar.dart';

class SeekerHomeScreen extends StatefulWidget {
  const SeekerHomeScreen({Key? key}) : super(key: key);

  @override
  _SeekerHomeScreenState createState() => _SeekerHomeScreenState();
}

class _SeekerHomeScreenState extends State<SeekerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  int _currentIndex = 0;

  // Sample data - Replace with actual data from your backend
  final List<CategoryModel> _categories = [
    CategoryModel(id: '1', name: 'All', icon: 'work', jobCount: 120),
    CategoryModel(id: '2', name: 'Development', icon: 'code', jobCount: 45),
    CategoryModel(id: '3', name: 'Design', icon: 'design', jobCount: 32),
    CategoryModel(id: '4', name: 'Marketing', icon: 'business', jobCount: 28),
    CategoryModel(id: '5', name: 'Finance', icon: 'attach_money', jobCount: 15),
  ];

  // Sample jobs - Replace with actual data from your backend
  final List<JobModel> _jobs = [
    JobModel(
      id: '1',
      employerId: 'emp1',
      title: 'Senior Flutter Developer',
      description: 'We are looking for an experienced Flutter developer...',
      location: 'Remote',
      salary: 8000,
      jobType: 'Full-time',
      requirements: ['3+ years of Flutter experience', 'Strong Dart skills'],
      skillsRequired: ['Flutter', 'Dart', 'Firebase'],
      companyName: 'TechCorp',
      category: 'Development',
    ),
    JobModel(
      id: '2',
      employerId: 'emp2',
      title: 'UI/UX Designer',
      description: 'Looking for a creative UI/UX designer...',
      location: 'New York, NY',
      salary: 7000,
      jobType: 'Full-time',
      requirements: ['2+ years of UI/UX experience', 'Portfolio required'],
      skillsRequired: ['Figma', 'Sketch', 'Adobe XD'],
      companyName: 'DesignHub',
      category: 'Design',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Find Your Dream Job'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              const Text(
                'Hello, Job Seeker!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find your perfect job',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar
              CustomSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  // Handle search
                },
                onSearchPressed: () {
                  // Handle search
                },
                onFilterPressed: () {
                  // Show filter options
                },
              ),
              const SizedBox(height: 24),

              // Categories
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return CategoryChip(
                      category: _categories[index],
                      isSelected: _selectedCategoryIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                          // Filter jobs by category
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Popular Jobs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Jobs',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all jobs
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Job List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _jobs.length,
                itemBuilder: (context, index) {
                  final job = _jobs[index];
                  return JobCard(
                    job: job,
                    onTap: () {
                      // Navigate to job details
                      // Get.to(() => JobDetailsScreen(job: job));
                    },
                    onSave: () {
                      // Save job
                      _saveJob(job);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Handle navigation
            switch (index) {
              case 0:
                // Already on home
                break;
              case 1:
                // Navigate to search
                // Get.to(() => SearchScreen());
                break;
              case 2:
                // Navigate to saved
                // Get.to(() => SavedJobsScreen());
                break;
              case 3:
                // Navigate to profile
                // Get.to(() => ProfileScreen());
                break;
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
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

  void _saveJob(JobModel job) {
    // Implement save job functionality
    Get.snackbar(
      'Job Saved',
      '${job.title} has been saved to your list',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
