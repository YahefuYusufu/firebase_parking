import 'package:firebase_parking/domain/entities/issue_entity.dart';

abstract class IssueRepository {
  Future<IssueEntity> createIssue(IssueEntity issue);
  Future<List<IssueEntity>> getUserIssues(String userId);
  Future<List<IssueEntity>> getAllIssues();
  Future<IssueEntity> updateIssue(IssueEntity issue);
}
