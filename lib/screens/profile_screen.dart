import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _experienceController;
  late TextEditingController _skillsController;
  late TextEditingController _resumeUrlController;
  bool _isEditing = false;
  bool _isLoading = false;
  String? _profileImageUrl;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _experienceController = TextEditingController();
    _skillsController = TextEditingController();
    _resumeUrlController = TextEditingController();

    _loadUserData();
  }

  void _loadUserData() {
    final user = _authController.user;
    if (user != null) {
      _nameController.text = user.displayName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _experienceController.text = user.experience ?? '';
      _skillsController.text = user.skills?.join(', ') ?? '';
      _resumeUrlController.text = user.resumeUrl ?? '';
      _profileImageUrl = user.photoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    _resumeUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authController.user!;
      await _authController.updateProfile(
        displayName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        experience: _experienceController.text.trim(),
        resumeUrl: _resumeUrlController.text.trim().isEmpty
            ? null
            : _resumeUrlController.text.trim(),
        skills: _skillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        photoUrl: _profileImageUrl,
      );

      await _authController.loadUserData(); // reload updated data
      Get.snackbar('Success', 'Profile updated successfully');
      setState(() => _isEditing = false);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = _authController.user;

      if (user == null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Please sign in to view profile'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed('/login'),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                  _loadUserData();
                },
              ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _authController.signOut();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
                ),
                const SizedBox(height: 20),
                _buildField('Full Name', _nameController, Icons.person,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter name' : null),
                _buildField('Email', _emailController, Icons.email,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter email' : null,
                    keyboardType: TextInputType.emailAddress),
                _buildField('Phone', _phoneController, Icons.phone,
                    keyboardType: TextInputType.phone),
                _buildField('Experience', _experienceController, Icons.work,
                    maxLines: 3),
                _buildField('Skills (comma separated)', _skillsController,
                    Icons.code,
                    hint: 'Flutter, Dart, Firebase'),
                _buildField(
                    'Resume URL', _resumeUrlController, Icons.insert_drive_file,
                    keyboardType: TextInputType.url),
                const SizedBox(height: 20),
                if (_isEditing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() => _isEditing = false);
                          _loadUserData();
                        },
                        child: const Text('CANCEL'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text('SAVE'),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('User Type', user.userType.toUpperCase()),
                      if (user.experience?.isNotEmpty ?? false)
                        _buildInfoRow('Experience', user.experience!),
                      if (user.skills?.isNotEmpty ?? false)
                        _buildInfoRow('Skills', user.skills!.join(', ')),
                      if (user.resumeUrl != null && user.resumeUrl!.isNotEmpty)
                        GestureDetector(
                          onTap: () async {
                            final url = Uri.parse(user.resumeUrl!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              Get.snackbar('Error', 'Cannot open URL');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.link, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'View Resume',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      decoration: TextDecoration.underline),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildField(String label, TextEditingController controller,
      IconData icon,
      {String? hint,
      TextInputType? keyboardType,
      String? Function(String?)? validator,
      int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0)),
        ),
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        readOnly: !_isEditing,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
