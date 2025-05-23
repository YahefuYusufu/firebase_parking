import 'package:firebase_parking/data/datasources/issue_data_source.dart';
import 'package:firebase_parking/data/models/issue/issue_model.dart';
import 'package:firebase_parking/domain/entities/issue_entity.dart';
import 'package:firebase_parking/domain/repositories/issue_repository.dart';

class IssueRepositoryImpl implements IssueRepository {
  final IssueDataSource dataSource;

  IssueRepositoryImpl({required this.dataSource});

  @override
  Future<IssueEntity> createIssue(IssueEntity issue) async {
    final issueModel = IssueModel.fromEntity(issue);
    final createdIssue = await dataSource.createIssue(issueModel);
    return createdIssue.toEntity();
  }

  @override
  Future<List<IssueEntity>> getUserIssues(String userId) async {
    final issueModels = await dataSource.getUserIssues(userId);
    return issueModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<IssueEntity>> getAllIssues() async {
    final issueModels = await dataSource.getAllIssues();
    return issueModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<IssueEntity> updateIssue(IssueEntity issue) async {
    final issueModel = IssueModel.fromEntity(issue);
    final updatedIssue = await dataSource.updateIssue(issueModel);
    return updatedIssue.toEntity();
  }
}
