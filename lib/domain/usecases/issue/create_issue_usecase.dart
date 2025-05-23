import 'package:firebase_parking/domain/entities/issue_entity.dart';
import 'package:firebase_parking/domain/repositories/issue_repository.dart';

class CreateIssueUseCase {
  final IssueRepository repository;

  CreateIssueUseCase(this.repository);

  Future<IssueEntity> call(String userId, String userName, String issueText) async {
    final issue = IssueEntity(userId: userId, userName: userName, issueText: issueText, createdAt: DateTime.now());

    return await repository.createIssue(issue);
  }
}
