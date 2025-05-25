import 'package:firebase_parking/domain/usecases/issue/create_issue_usecase.dart';
import 'package:firebase_parking/domain/usecases/issue/get_user_issues_usecase.dart';
import 'package:firebase_parking/presentation/blocs/issue/issue_event.dart';
import 'package:firebase_parking/presentation/blocs/issue/issue_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class IssueBloc extends Bloc<IssueEvent, IssueState> {
  final CreateIssueUseCase createIssue;
  final GetUserIssuesUseCase getUserIssues;

  IssueBloc({required this.createIssue, required this.getUserIssues}) : super(IssueInitial()) {
    on<CreateIssueEvent>(_onCreateIssue);
    on<GetUserIssuesEvent>(_onGetUserIssues);
  }

  Future<void> _onCreateIssue(CreateIssueEvent event, Emitter<IssueState> emit) async {
    emit(IssueLoading());

    try {
      final issue = await createIssue(event.userId, event.userName, event.issueText);
      emit(IssueCreated(issue));
    } catch (e) {
      emit(IssueError(e.toString()));
    }
  }

  Future<void> _onGetUserIssues(GetUserIssuesEvent event, Emitter<IssueState> emit) async {
    emit(IssueLoading());

    try {
      final issues = await getUserIssues(event.userId);
      emit(IssuesLoaded(issues));
    } catch (e) {
      emit(IssueError(e.toString()));
    }
  }
}
