import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final UserRepository _repo;
  final Rxn<UserModel> _userModel = Rxn<UserModel>();
  UserModel? get user => _userModel.value;
  bool get isLoggedIn => user != null;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserModel?>? _userSub;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    try {
      _repo = Get.find<UserRepository>();
      _setupAuthListener();
    } catch (e) {
      print('Error initializing AuthController: $e');
      // Try to reinitialize after a delay
      await Future.delayed(Duration(seconds: 1));
      _init();
    }
  }

  void _setupAuthListener() {
    _authSub = _auth.authStateChanges().listen((fbUser) {
      _userSub?.cancel();
      if (fbUser == null) {
        _userModel.value = null;
        // Ensure user lands on login
        Get.offAllNamed('/login');
      } else {
        // Subscribe to user profile doc and react
        _userSub = _repo.streamUser(fbUser.uid).listen((profile) {
          _userModel.value = profile;
          // Only navigate when profile is available (not null)
          if (profile != null) {
            if (profile.userType == 'job_seeker') {
              Get.offAllNamed('/seeker');
            } else if (profile.userType == 'employer') {
              Get.offAllNamed('/employer');
            } else {
              // fallback to login
              Get.offAllNamed('/login');
            }
          } else {
            // If profile missing, send to signup to complete registration
            Get.offAllNamed('/signup');
          }
        });
      }
    });
  }

  // Register and create Firestore profile
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required String userType, // 'job_seeker' or 'employer'
    String? photoUrl,
    String? resumeUrl,
  }) async {
    try {
      if (email.isEmpty || password.length < 6) {
        throw Exception('Provide valid email and 6+ char password');
      }
      
      // Check if email exists
      final exists = await _repo.checkEmailExists(email);
      if (exists) throw Exception('Email already registered');

      // Create Firebase Auth user
      print('Creating Firebase Auth user...');
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(), 
        password: password
      );
      
      final fbUser = cred.user;
      if (fbUser == null) throw Exception('Failed to create user account');
      
      print('Firebase Auth user created: ${fbUser.uid}');
      
      // Create user profile in Firestore
      final model = UserModel(
        id: fbUser.uid,
        email: email.trim().toLowerCase(),
        displayName: displayName,
        userType: userType,
        photoUrl: photoUrl,
        resumeUrl: resumeUrl,
      );
      
      print('Saving user profile to Firestore...');
      await _repo.createOrUpdateUser(model);
      print('User profile saved successfully');
      
      // _auth state listener will pick up the change and handle navigation
    } catch (e) {
      print('Error during registration: $e');
      rethrow; // Re-throw to show error in UI
    }
  }

  // Login and ensure we read profile
  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) throw Exception('Enter credentials');
    final cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    final fbUser = cred.user;
    if (fbUser == null) throw Exception('Login failed');
    // no navigation here; stream listener will fetch profile and redirect.
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userModel.value = null;
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _userSub?.cancel();
    super.onClose();
  }
}
