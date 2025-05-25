import 'package:equatable/equatable.dart';

abstract class IssueEvent extends Equatable {
  const IssueEvent();

  @override
  List<Object> get props => [];
}

class CreateIssueEvent extends IssueEvent {
  final String userId;
  final String userName;
  final String issueText;

  const CreateIssueEvent({required this.userId, required this.userName, required this.issueText});

  @override
  List<Object> get props => [userId, userName, issueText];
}

class GetUserIssuesEvent extends IssueEvent {
  final String userId;

  const GetUserIssuesEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
