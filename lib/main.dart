import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:job_portal_app/controllers/auth_controller.dart';
import 'package:job_portal_app/controllers/job_controller.dart';
import 'package:job_portal_app/repositories/job_repository.dart';
import 'package:job_portal_app/repositories/user_repository.dart';
import 'package:job_portal_app/screens/login_screen.dart';
import 'package:job_portal_app/screens/signup_screen.dart';
import 'package:job_portal_app/screens/seeker/seeker_home_screen.dart';
import 'package:job_portal_app/screens/employer/employer_home_screen.dart';
import 'package:job_portal_app/screens/job_details_screen.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize repositories
    Get.put(UserRepository(), permanent: true);
    Get.put(JobRepository(), permanent: true);
    
    // Initialize controllers
    Get.put(AuthController(), permanent: true);
    Get.put(JobController(), permanent: true);
    
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
    // You might want to show an error UI here
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Job Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4361EE),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF4361EE),  // Primary blue
          secondary: const Color(0xFF3F37C9), // Darker blue
          surface: Colors.white,
          background: const Color(0xFFF8F9FA), // Light gray background
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF212529), // Dark gray for text
          onBackground: const Color(0xFF212529),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: const Color(0xFF4361EE),
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4361EE), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintStyle: TextStyle(color: Colors.grey[500]),
          labelStyle: const TextStyle(color: Color(0xFF495057)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4361EE),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        textTheme: TextTheme(
          displayMedium: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212529),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: const Color(0xFF495057).withOpacity(0.9),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: const Color(0xFF6C757D).withOpacity(0.9),
          ),
          labelLarge: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/seeker', page: () => SeekerHomeScreen()),
        GetPage(name: '/employer', page: () => EmployerHomeScreen()),
        GetPage(name: '/job_details', page: () {
          final jobId = Get.arguments as String;
          return FutureBuilder<JobModel?>(
            future: Get.find<JobRepository>().getJobById(jobId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Scaffold(
                  body: Center(child: Text('Job not found')),
                );
              }
              return JobDetailsScreen(job: snapshot.data!);
            },
          );
        }),
      ],
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Failed to initialize the app. Please try again later.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Try to restart the app
                  main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
