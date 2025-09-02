import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final UserRepository _repo;

  final Rxn<UserModel> _userModel = Rxn<UserModel>();

  UserModel? get user => _userModel.value;
  bool get isLoggedIn => user != null;
  String? get userType => user?.userType;
  Stream<UserModel?> get userStream => _userModel.stream;

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
      Future.delayed(const Duration(seconds: 1), _init);
    }
  }

  void _setupAuthListener() {
    _authSub = _auth.authStateChanges().listen((fbUser) {
      _userSub?.cancel();
      if (fbUser == null) {
        _userModel.value = null;
        Get.offAllNamed('/login');
      } else {
        _userSub = _repo.streamUser(fbUser.uid).listen((profile) {
          _userModel.value = profile;
          if (profile != null) {
            switch (profile.userType) {
              case 'job_seeker':
                Get.offAllNamed('/seeker');
                break;
              case 'employer':
                Get.offAllNamed('/employer');
                break;
              default:
                Get.offAllNamed('/login');
            }
          } else {
            Get.offAllNamed('/signup');
          }
        });
      }
    });
  }

  /// Register and create Firestore profile
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required String userType,
    String? photoUrl,
    String? resumeUrl,
  }) async {
    try {
      if (email.isEmpty || password.length < 6) {
        throw Exception('Provide valid email and 6+ char password');
      }

      final exists = await _repo.checkEmailExists(email);
      if (exists) throw Exception('Email already registered');

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final fbUser = cred.user;
      if (fbUser == null) throw Exception('Failed to create user account');

      // Set initial displayName in Firebase Auth
      await fbUser.updateDisplayName(displayName);

      final model = UserModel(
        id: fbUser.uid,
        email: email.trim().toLowerCase(),
        displayName: displayName,
        userType: userType,
        photoUrl: photoUrl,
        resumeUrl: resumeUrl,
      );
      await _repo.createOrUpdateUser(model);
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    }
  }

  /// Login with email & password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Enter credentials');
    }
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (cred.user == null) throw Exception('Login failed');
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _userModel.value = null;
    Get.offAllNamed('/login');
  }

  /// Update profile in Firebase + Firestore
  Future<void> updateProfile({
    required String displayName,
    required String email,
    String? phoneNumber,
    String? experience,
    String? resumeUrl,
    String? photoUrl,
    List<String>? skills,
    int? experienceYears,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      // 🔹 Update email if changed
      if (email.trim() != currentUser.email) {
        await currentUser.verifyBeforeUpdateEmail(email.trim());
        // verifyBeforeUpdateEmail is safer (sends confirmation email)
      }

      // 🔹 Update display name if changed
      if (displayName.trim() != (currentUser.displayName ?? '')) {
        await currentUser.updateDisplayName(displayName.trim());
      }

      await currentUser.reload();

      // 🔹 Update Firestore profile
      final updatedUser = _userModel.value!.copyWith(
        displayName: displayName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber,
        experience: experience,
        resumeUrl: resumeUrl,
        photoUrl: photoUrl,
        skills: skills,
        experienceYears: experienceYears,
      );

      await _repo.createOrUpdateUser(updatedUser);
      _userModel.value = updatedUser;
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Reload user data from Firestore
  Future<void> loadUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userData = await _repo.getUser(currentUser.uid);
      if (userData != null) {
        _userModel.value = userData;
      }
    }
  }

  /// Launch external URL
  Future<void> launchURL(String? url) async {
    if (url == null || url.isEmpty) return;

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _userSub?.cancel();
    super.onClose();
  }
}
