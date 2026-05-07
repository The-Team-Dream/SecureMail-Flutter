class AttachmentModel {
  final int id;
  final String filename;
  final String mimeType;
  final int size;
  final String? storagePath;

  AttachmentModel({
    required this.id,
    required this.filename,
    required this.mimeType,
    required this.size,
    this.storagePath,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id:          json['id'] as int,
      filename:    json['filename'] as String? ?? 'Unnamed',
      mimeType:    json['mimeType'] as String? ?? 'application/octet-stream',
      size:        json['size'] as int? ?? 0,
      storagePath: json['storagePath'] as String?,
    );
  }
}
