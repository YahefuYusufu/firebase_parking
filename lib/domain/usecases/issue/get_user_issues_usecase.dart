import 'package:firebase_parking/domain/entities/issue_entity.dart';
import 'package:firebase_parking/domain/repositories/issue_repository.dart';

class GetUserIssuesUseCase {
  final IssueRepository repository;

  GetUserIssuesUseCase(this.repository);

  Future<List<IssueEntity>> call(String userId) async {
    return await repository.getUserIssues(userId);
  }
}
