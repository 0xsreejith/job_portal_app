import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_portal_app/controllers/auth_controller.dart';
import 'package:job_portal_app/controllers/job_controller.dart';
import 'package:job_portal_app/models/job_model.dart';

class AddJobScreen extends StatefulWidget {
  final JobModel? job;

  const AddJobScreen({Key? key, this.job}) : super(key: key);

  @override
  _AddJobScreenState createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late final JobController _jobController;
  late final AuthController _authController;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _jobController = Get.find<JobController>();
    _authController = Get.find<AuthController>();
  }
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _jobTypeController = TextEditingController();
  final _experienceLevelController = TextEditingController();
  final _categoryController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _skillsController = TextEditingController();
  final _deadlineController = TextEditingController();

  List<String> requirements = [];
  List<String> skills = [];
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _titleController.text = widget.job!.title;
      _descriptionController.text = widget.job!.description;
      _locationController.text = widget.job!.location;
      _salaryController.text = widget.job!.salary.toString();
      _jobTypeController.text = widget.job!.jobType;
      _experienceLevelController.text = widget.job!.experienceLevel ?? '';
      _categoryController.text = widget.job!.category ?? '';
      requirements = List.from(widget.job!.requirements);
      skills = List.from(widget.job!.skillsRequired);
      isActive = widget.job!.isActive;
      if (widget.job!.applicationDeadline != null) {
        _deadlineController.text = widget.job!.applicationDeadline!.toIso8601String().split('T')[0];
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _jobTypeController.dispose();
    _experienceLevelController.dispose();
    _categoryController.dispose();
    _requirementsController.dispose();
    _skillsController.dispose();
    _deadlineController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _addRequirement() {
    if (_requirementsController.text.isNotEmpty) {
      setState(() {
        requirements.add(_requirementsController.text);
        _requirementsController.clear();
      });
    }
  }

  void _removeRequirement(String requirement) {
    setState(() {
      requirements.remove(requirement);
    });
  }

  void _addSkill() {
    if (_skillsController.text.isNotEmpty) {
      setState(() {
        skills.add(_skillsController.text);
        _skillsController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      skills.remove(skill);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (requirements.isEmpty) {
      Get.snackbar('Error', 'Please add at least one requirement');
      return;
    }
    if (skills.isEmpty) {
      Get.snackbar('Error', 'Please add at least one required skill');
      return;
    }

    // Get the current user safely
    final user = _authController.user;
    if (user == null) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    final job = JobModel(
      id: widget.job?.id ?? '',
      employerId: user.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      salary: double.tryParse(_salaryController.text.trim()) ?? 0,
      jobType: _jobTypeController.text.trim(),
      requirements: requirements,
      skillsRequired: skills,
      isActive: isActive,
      companyName: user.displayName ?? 'Company',
      experienceLevel: _experienceLevelController.text.trim().isNotEmpty
          ? _experienceLevelController.text.trim()
          : null,
      category: _categoryController.text.trim().isNotEmpty
          ? _categoryController.text.trim()
          : null,
      applicationDeadline: _deadlineController.text.isNotEmpty
          ? DateTime.parse(_deadlineController.text)
          : null,
    );

    try {
      if (widget.job == null) {
        await _jobController.createJob(job);
      } else {
        await _jobController.updateJob(job);
      }
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save job: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job == null ? 'Post a New Job' : 'Edit Job'),
        actions: [
          if (widget.job != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Get.defaultDialog(
                  title: 'Delete Job',
                  middleText: 'Are you sure you want to delete this job posting?',
                  textConfirm: 'Delete',
                  textCancel: 'Cancel',
                  confirmTextColor: Colors.white,
                  onConfirm: () async {
                    final user = _authController.user;
                    if (user == null) {
                      Get.snackbar('Error', 'User not authenticated');
                      return;
                    }
                    await _jobController.deleteJob(
                      widget.job!.id,
                      user.id,
                    );
                    Get.back();
                    Get.back();
                  },
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a job title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a job description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Remote, New York, NY',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _salaryController,
                      decoration: const InputDecoration(
                        labelText: 'Salary',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a salary';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _jobTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Job Type',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Full-time',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter job type';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _experienceLevelController,
                      decoration: const InputDecoration(
                        labelText: 'Experience Level',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Mid-level',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Software Development',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Application Deadline (optional):'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deadlineController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              const Text('Requirements:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _requirementsController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Add a requirement',
                      ),
                      onFieldSubmitted: (_) => _addRequirement(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addRequirement,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: requirements
                    .map(
                      (req) => Chip(
                        label: Text(req),
                        onDeleted: () => _removeRequirement(req),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text('Required Skills:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Add a required skill',
                      ),
                      onFieldSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSkill,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: skills
                    .map(
                      (skill) => Chip(
                        label: Text(skill),
                        onDeleted: () => _removeSkill(skill),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active Job Posting'),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Obx(() => _jobController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(widget.job == null ? 'Post Job' : 'Update Job'),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
