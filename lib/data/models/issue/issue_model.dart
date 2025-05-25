import 'package:firebase_parking/domain/entities/issue_entity.dart';

class IssueModel extends IssueEntity {
  const IssueModel({super.id, required super.userId, required super.userName, required super.issueText, required super.createdAt, super.status = 'open'});

  factory IssueModel.fromFirestore(Map<String, dynamic> data, String id) {
    return IssueModel(
      id: id,
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? '',
      issueText: data['issue_text'] ?? '',
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
      status: data['status'] ?? 'open',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'user_id': userId, 'user_name': userName, 'issue_text': issueText, 'created_at': createdAt.toIso8601String(), 'status': status};
  }

  factory IssueModel.fromEntity(IssueEntity entity) {
    return IssueModel(id: entity.id, userId: entity.userId, userName: entity.userName, issueText: entity.issueText, createdAt: entity.createdAt, status: entity.status);
  }

  IssueEntity toEntity() {
    return IssueEntity(id: id, userId: userId, userName: userName, issueText: issueText, createdAt: createdAt, status: status);
  }

  // Add the copyWith method that returns IssueModel instead of IssueEntity
  @override
  IssueModel copyWith({String? id, String? userId, String? userName, String? issueText, DateTime? createdAt, String? status}) {
    return IssueModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      issueText: issueText ?? this.issueText,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
