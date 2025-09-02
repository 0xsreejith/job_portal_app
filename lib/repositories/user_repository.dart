import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update user profile in Firestore
  Future<void> createOrUpdateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // Get user profile stream by ID
  Stream<UserModel?> streamUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap({...doc.data()!, 'id': doc.id});
    });
  }

  // Get user once
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final fileName = 'profile_$userId${path.extension(imageFile.path)}';
      final ref = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow;
    }
  }

  // Upload resume
  Future<String> uploadResume(File resumeFile, String userId) async {
    try {
      final fileName = 'resume_$userId${path.extension(resumeFile.path)}';
      final ref = FirebaseStorage.instance.ref().child('resumes/$fileName');
      final uploadTask = ref.putFile(resumeFile);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading resume: $e');
      rethrow;
    }
  }
}
