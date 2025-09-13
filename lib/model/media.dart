class Media {
  final String id;
  final String logoUrl;
  final String subLogoUrl;

  Media({
    required this.id,
    required this.logoUrl,
    required this.subLogoUrl,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      logoUrl: json['logoUrl'] ?? '',
      subLogoUrl: json['subLogoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'logoUrl': logoUrl,
    'subLogoUrl': subLogoUrl,
  };
}
