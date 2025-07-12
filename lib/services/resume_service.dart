import 'package:cloud_firestore/cloud_firestore.dart';

class ResumeService {
  // Insert resume data into Firestore (CREATE)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> insertResume(Map<String, dynamic> data, String resumeId) async {
  await _firestore.collection('resumes').doc(resumeId).set(data);
  }

  Future<void> updateResume(Map<String, dynamic> data, String resumeId) async {
  await _firestore.collection('resumes').doc(resumeId).update(data);
  }

  Future<DocumentSnapshot> getResumeById(String resumeId) async {
  return await _firestore.collection('resumes').doc(resumeId).get();
  }


  // Retrieve all resumes as a stream (READ ALL)
  Future<Stream<QuerySnapshot>> retrieveResumes() async {
    return FirebaseFirestore.instance.collection('resumes').snapshots();
  }



  // Delete resume from Firestore (DELETE)
  Future<void> deleteResume(String ID) async {
    await FirebaseFirestore.instance.collection('resumes').doc(ID).delete();
  }


}
