import 'email_model.dart';

class PaginatedEmailsModel {
  final List<EmailModel> data;
  final PaginationMeta meta;

  PaginatedEmailsModel({
    required this.data,
    required this.meta,
  });

  factory PaginatedEmailsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedEmailsModel(
      data: (json['data'] as List).map((e) => EmailModel.fromJson(e)).toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total:      json['total'] as int,
      page:       json['page'] as int,
      limit:      json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
