import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'user_profile.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Get current user's profile
  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProfile.fromMap(uid, snapshot.data()!);
    });
  }

  // Get profile once
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(uid, doc.data()!);
  }

  // Update profile
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? email,
    String? phoneNumber,
  }) async {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};

    if (displayName != null) {
      data['displayName'] = displayName;
      // Update Firebase Auth display name
      await _auth.currentUser?.updateDisplayName(displayName);
    }
    if (email != null) data['email'] = email;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;

    await _firestore.collection('users').doc(uid).update(data);
  }

  // Update profile photo with URL
  Future<void> updateProfilePhotoUrl(String uid, String photoUrl) async {
    try {
      // Update Firestore
      await _firestore.collection('users').doc(uid).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Firebase Auth photo URL
      await _auth.currentUser?.updatePhotoURL(photoUrl);
    } catch (e) {
      debugPrint('Error updating profile photo URL: $e');
      rethrow;
    }
  }

  // Upload profile photo
  Future<String?> uploadProfilePhoto(String uid) async {
    try {
      // Pick image from gallery
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return null;

      // Upload to Firebase Storage
      final file = File(image.path);
      final storageRef = _storage.ref().child('profile_photos/$uid.jpg');

      await storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get download URL
      final photoUrl = await storageRef.getDownloadURL();

      // Update Firestore
      await _firestore.collection('users').doc(uid).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Firebase Auth photo URL
      await _auth.currentUser?.updatePhotoURL(photoUrl);

      return photoUrl;
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      return null;
    }
  }

  // Delete profile photo
  Future<void> deleteProfilePhoto(String uid) async {
    try {
      // Delete from Storage
      final storageRef = _storage.ref().child('profile_photos/$uid.jpg');
      await storageRef.delete();
    } catch (e) {
      debugPrint('Error deleting from storage: $e');
    }

    // Remove URL from Firestore
    await _firestore.collection('users').doc(uid).update({
      'photoUrl': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update Firebase Auth
    await _auth.currentUser?.updatePhotoURL(null);
  }

  // Delete entire profile (except auth)
  Future<void> deleteProfileData(String uid) async {
    // Delete profile photo if exists
    try {
      await deleteProfilePhoto(uid);
    } catch (e) {
      debugPrint('No photo to delete');
    }

    // Clear profile data in Firestore
    await _firestore.collection('users').doc(uid).update({
      'displayName': FieldValue.delete(),
      'phoneNumber': FieldValue.delete(),
      'photoUrl': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update Firebase Auth
    await _auth.currentUser?.updateDisplayName(null);
    await _auth.currentUser?.updatePhotoURL(null);
  }
}
