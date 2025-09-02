import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:job_portal_app/models/user_model.dart';
import 'package:job_portal_app/repositories/user_repository.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;
  StreamSubscription<UserModel?>? _userSubscription;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isEmployer => _currentUser?.userType == 'employer';
  bool get isJobSeeker => _currentUser?.userType == 'job_seeker';
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Initialize auth service
  Future<void> initialize() async {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        // User is signed in
        await _setupUser(user.uid);
      } else {
        // User is signed out
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Set up user data when authenticated
  Future<void> _setupUser(String userId) async {
    _userSubscription?.cancel();
    _userSubscription = _userRepository.streamUser(userId).listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password, {
    String? userType,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) return null;

      // If this is a new user and userType is provided, create user profile
      if (userCredential.additionalUserInfo?.isNewUser == true && userType != null) {
        await _createUserProfile(userCredential.user!, userType: userType);
      }

      // Get the updated user data
      return await _userRepository.getUserById(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Register with email and password
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String userType,
  }) async {
    try {
      // Check if email already exists
      final emailExists = await _userRepository.checkEmailExists(email);
      if (emailExists) {
        throw Exception('Email is already in use');
      }

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      // Create user profile
      await _createUserProfile(
        userCredential.user!,
        displayName: displayName,
        userType: userType,
      );

      // Return the created user
      return (await _userRepository.getUserById(userCredential.user!.uid))!;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Create or update user profile in Firestore
  Future<void> _createUserProfile(
    User user, {
    String? displayName,
    required String userType,
  }) async {
    final userModel = UserModel(
      id: user.uid,
      email: user.email!,
      displayName: displayName ?? user.displayName ?? user.email!.split('@')[0],
      photoUrl: user.photoURL,
      userType: userType,
    );

    await _userRepository.createOrUpdateUser(userModel);
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle({String? userType}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user == null) return null;

      // If this is a new user and userType is provided, create user profile
      if (userCredential.additionalUserInfo?.isNewUser == true && userType != null) {
        await _createUserProfile(
          userCredential.user!,
          displayName: googleUser.displayName,
          userType: userType,
        );
      }

      // Get the updated user data
      return await _userRepository.getUserById(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentUser = null;
      _userSubscription?.cancel();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _userRepository.updateUserProfile(
        userId: userId,
        updates: updates,
      );
      // Refresh current user data
      _currentUser = await _userRepository.getUserById(userId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile. Please try again.');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _userRepository.deleteUserAccount(user.uid);
        await user.delete();
        _currentUser = null;
        _userSubscription?.cancel();
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account. Please try again.');
    }
  }

  // Handle Firebase auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Dispose method to cancel subscriptions
  @override
  void dispose() {
    _userSubscription?.cancel();
    _auth.signOut(); // Ensure clean sign out on dispose
    super.dispose();
  }
}
