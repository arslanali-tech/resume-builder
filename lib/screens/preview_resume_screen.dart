import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/resume_service.dart';

class PreviewResumeScreen extends StatefulWidget {
  final String resumeId;

  PreviewResumeScreen({required this.resumeId});

  @override
  _PreviewResumeScreenState createState() => _PreviewResumeScreenState();
}

class _PreviewResumeScreenState extends State<PreviewResumeScreen> {
  Map<String, dynamic>? resumeData;
  bool isLoading = true;
  final ResumeService _resumeService = ResumeService();

  @override
  void initState() {
    super.initState();
    _loadResumeData();
  }

  Future<void> _loadResumeData() async {
    try {
      DocumentSnapshot resumeDoc = await _resumeService.getResumeById(
        widget.resumeId,
      );
      if (resumeDoc.exists) {
        setState(() {
          resumeData = resumeDoc.data() as Map<String, dynamic>;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading resume data')));
    }
  }

  Widget _buildSection(String title, String content, IconData icon) {
    if (content.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[600], size: 24),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey[300],
            ),
            SizedBox(height: 15),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
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
          'Resume Preview',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : resumeData == null
              ? Center(
                child: Text(
                  'Resume not found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section with personal info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[600]!, Colors.blue[700]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resumeData!['name'] ?? '',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          if (resumeData!['email']?.isNotEmpty ?? false)
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  resumeData!['email'],
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 5),
                          if (resumeData!['phone']?.isNotEmpty ?? false)
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  resumeData!['phone'],
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 5),
                          if (resumeData!['address']?.isNotEmpty ?? false)
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    resumeData!['address'],
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 25),

                    // Resume sections
                    _buildSection(
                      'Career Objective',
                      resumeData!['objective'] ?? '',
                      Icons.flag,
                    ),
                    _buildSection(
                      'Education',
                      resumeData!['education'] ?? '',
                      Icons.school,
                    ),
                    _buildSection(
                      'Work Experience',
                      resumeData!['experience'] ?? '',
                      Icons.work,
                    ),
                    _buildSection(
                      'Skills',
                      resumeData!['skills'] ?? '',
                      Icons.star,
                    ),
                    _buildSection(
                      'Projects',
                      resumeData!['projects'] ?? '',
                      Icons.folder,
                    ),
                    _buildSection(
                      'Certifications',
                      resumeData!['certifications'] ?? '',
                      Icons.card_membership,
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
    );
  }
}
