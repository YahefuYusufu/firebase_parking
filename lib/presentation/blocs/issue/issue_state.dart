import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/entities/issue_entity.dart';

abstract class IssueState extends Equatable {
  const IssueState();

  @override
  List<Object> get props => [];
}

class IssueInitial extends IssueState {}

class IssueLoading extends IssueState {}

class IssueCreated extends IssueState {
  final IssueEntity issue;

  const IssueCreated(this.issue);

  @override
  List<Object> get props => [issue];
}

class IssuesLoaded extends IssueState {
  final List<IssueEntity> issues;

  const IssuesLoaded(this.issues);

  @override
  List<Object> get props => [issues];
}

class IssueError extends IssueState {
  final String message;

  const IssueError(this.message);

  @override
  List<Object> get props => [message];
}
