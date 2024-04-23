class RewardDetail {
  final String id;
  final String name;
  final int point;
  final String title;
  final String description;
  final String expiredDate;
  final String previewImageUrl;
  final List<String> condition;
  final String webhook;
  final String createBy;

  RewardDetail({
    required this.id,
    required this.name,
    required this.point,
    required this.title,
    required this.description,
    required this.expiredDate,
    required this.previewImageUrl,
    required this.condition,
    required this.webhook,
    required this.createBy,
  });

  factory RewardDetail.fromJson(Map<String, dynamic> json) {
    return RewardDetail(
      id: json['ID'],
      name: json['Name'],
      point: json['Point'],
      title: json['Title'],
      description: json['Description'],
      expiredDate: json['ExpiredDate'],
      previewImageUrl: json['PreviewImageURL'],
      webhook: json['Webhook'],
      condition: List<String>.from(json['Condition']),
      createBy: json['CreateBy'],
    );
  }
}

class MyRewardDetail {
  final String id;
  final String name;
  final int point;
  final String title;
  final String description;
  final String previewUrl;
  final String webhook;
  final List<String> condition;
  final int quotaCount;
  final String createBy;
  final String barcodeUrl;
  final int customerExpiredDate;

  MyRewardDetail({
    required this.id,
    required this.name,
    required this.point,
    required this.title,
    required this.description,
    required this.previewUrl,
    required this.webhook,
    required this.condition,
    required this.quotaCount,
    required this.createBy,
    required this.barcodeUrl,
    required this.customerExpiredDate,
  });

  factory MyRewardDetail.fromJson(Map<String, dynamic> json) {
    return MyRewardDetail(
      id: json['_id'],
      name: json['name'],
      point: json['point'],
      title: json['title'],
      description: json['description'],
      previewUrl: json['preview_url'],
      webhook: json['webhook'],
      condition: List<String>.from(json['condition']),
      quotaCount: json['quota_count'],
      createBy: json['create_by'],
      barcodeUrl: json['barcode_url'],
      customerExpiredDate: json['customer_expired_date'],
    );
  }
}
