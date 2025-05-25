import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_parking/data/models/issue/issue_model.dart';

abstract class IssueDataSource {
  Future<IssueModel> createIssue(IssueModel issue);
  Future<List<IssueModel>> getUserIssues(String userId);
  Future<List<IssueModel>> getAllIssues();
  Future<IssueModel> updateIssue(IssueModel issue);
}

class FirebaseIssueDataSource implements IssueDataSource {
  final FirebaseFirestore _firestore;

  FirebaseIssueDataSource({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _issuesCollection => _firestore.collection('issues');

  @override
  Future<IssueModel> createIssue(IssueModel issue) async {
    final docRef = await _issuesCollection.add(issue.toFirestore());
    // Fix: Use the IssueModel copyWith method directly
    return issue.copyWith(id: docRef.id);
  }

  @override
  Future<List<IssueModel>> getUserIssues(String userId) async {
    final query = await _issuesCollection.where('user_id', isEqualTo: userId).orderBy('created_at', descending: true).get();

    return query.docs.map((doc) => IssueModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  @override
  Future<List<IssueModel>> getAllIssues() async {
    final query = await _issuesCollection.orderBy('created_at', descending: true).get();

    return query.docs.map((doc) => IssueModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  @override
  Future<IssueModel> updateIssue(IssueModel issue) async {
    await _issuesCollection.doc(issue.id).update(issue.toFirestore());
    return issue;
  }
}
