class StudyCard {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final String materialType; // 'text' or 'file'
  final String? materialContent;
  final String? materialFileUrl;
  final String? materialFileName;
  final String? materialFileType;
  final int? materialFileSize;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyCard({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.materialType,
    this.materialContent,
    this.materialFileUrl,
    this.materialFileName,
    this.materialFileType,
    this.materialFileSize,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyCard.fromJson(Map<String, dynamic> json) {
    return StudyCard(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      materialType: json['material_type'] as String? ?? 'text',
      materialContent: json['material_content'] as String?,
      materialFileUrl: json['material_file_url'] as String?,
      materialFileName: json['material_file_name'] as String?,
      materialFileType: json['material_file_type'] as String?,
      materialFileSize: json['material_file_size'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'material_type': materialType,
      'material_content': materialContent,
      'material_file_url': materialFileUrl,
      'material_file_name': materialFileName,
      'material_file_type': materialFileType,
      'material_file_size': materialFileSize,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isFileType => materialType == 'file';
  bool get isTextType => materialType == 'text';

  String? get fileSizeFormatted {
    if (materialFileSize == null) return null;
    
    double bytes = materialFileSize!.toDouble();
    List<String> units = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    
    while (bytes > 1024 && i < units.length - 1) {
      bytes /= 1024;
      i++;
    }
    
    return '${bytes.toStringAsFixed(2)} ${units[i]}';
  }
}
