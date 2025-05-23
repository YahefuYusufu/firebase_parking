class IssueEntity {
  final String? id;
  final String userId;
  final String userName;
  final String issueText;
  final DateTime createdAt;
  final String status; // 'open', 'in_progress', 'resolved'

  const IssueEntity({this.id, required this.userId, required this.userName, required this.issueText, required this.createdAt, this.status = 'open'});

  IssueEntity copyWith({String? id, String? userId, String? userName, String? issueText, DateTime? createdAt, String? status}) {
    return IssueEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      issueText: issueText ?? this.issueText,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
