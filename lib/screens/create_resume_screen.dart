import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/resume_service.dart';

class CreateResumeScreen extends StatefulWidget {
  final String? resumeId;

  CreateResumeScreen({this.resumeId});

  @override
  _CreateResumeScreenState createState() => _CreateResumeScreenState();
}

class _CreateResumeScreenState extends State<CreateResumeScreen> {
  final ResumeService _resumeService = ResumeService();
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _skillsController = TextEditingController();
  final _projectsController = TextEditingController();
  final _certificationsController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.resumeId != null) {
      _isEditing = true;
      _loadResumeData();
    }
  }

  Future<void> _loadResumeData() async {
    try {
      DocumentSnapshot resumeDoc = await _resumeService.getResumeById(
        widget.resumeId!,
      );
      if (resumeDoc.exists) {
        final data = resumeDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _objectiveController.text = data['objective'] ?? '';
          _educationController.text = data['education'] ?? '';
          _experienceController.text = data['experience'] ?? '';
          _skillsController.text = data['skills'] ?? '';
          _projectsController.text = data['projects'] ?? '';
          _certificationsController.text = data['certifications'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading resume data')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _objectiveController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    _projectsController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  Future<void> _saveResume() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Map<String, dynamic> resumeData = {
            'userId': user.uid,
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
            'objective': _objectiveController.text.trim(),
            'education': _educationController.text.trim(),
            'experience': _experienceController.text.trim(),
            'skills': _skillsController.text.trim(),
            'projects': _projectsController.text.trim(),
            'certifications': _certificationsController.text.trim(),
          };

          if (_isEditing) {
            await _resumeService.updateResume(resumeData, widget.resumeId!);
          } else {
            await _resumeService.insertResume(
              resumeData,
              user.uid + DateTime.now().millisecondsSinceEpoch.toString(),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Resume updated successfully'
                    : 'Resume created successfully',
              ),
            ),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving resume. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blue[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Resume' : 'Create Resume',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 15),

              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter your address',
                icon: Icons.location_on,
                maxLines: 2,
              ),

              SizedBox(height: 20),

              // Objective Section
              Text(
                'Career Objective',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 15),

              _buildTextField(
                controller: _objectiveController,
                label: 'Objective',
                hint: 'Describe your career objective',
                icon: Icons.flag,
                maxLines: 3,
              ),

              SizedBox(height: 20),

              // Education Section
              Text(
                'Education',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 15),

              _buildTextField(
                controller: _educationController,
                label: 'Education',
                hint: 'Enter your educational background',
                icon: Icons.school,
                maxLines: 4,
              ),

              SizedBox(height: 20),

              // Experience Section
              Text(
                'Work Experience',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 15),

              _buildTextField(
                controller: _experienceController,
                label: 'Experience',
                hint: 'Enter your work experience',
                icon: Icons.work,
                maxLines: 4,
              ),

              SizedBox(height: 20),

              // Skills Section
              Text(
                'Skills',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 15),

              _buildTextField(
                controller: _skillsController,
                label: 'Skills',
                hint: 'List your skills (comma separated)',
                icon: Icons.star,
                maxLines: 3,
              ),

              SizedBox(height: 20),

              // Projects Section
              Text(
                'Projects',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 15),

              _buildTextField(
                controller: _projectsController,
                label: 'Projects',
                hint: 'Describe your projects',
                icon: Icons.folder,
                maxLines: 4,
              ),

              SizedBox(height: 20),

              // Certifications Section
              Text(
                'Certifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 15),

              _buildTextField(
                controller: _certificationsController,
                label: 'Certifications',
                hint: 'List your certifications',
                icon: Icons.card_membership,
                maxLines: 3,
              ),

              SizedBox(height: 30),

              // Save button
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveResume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                            _isEditing ? 'Update Resume' : 'Save Resume',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
