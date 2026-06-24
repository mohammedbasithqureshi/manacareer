class Opportunity {
  final String id;
  final String title;
  final String org;
  final String type;
  final String district;
  final String location;
  final String money;
  final String deadline;
  final bool urgent;
  final String about;
  final List<String> eligibility;
  final String applyInfo;

  Opportunity({
    required this.id,
    required this.title,
    required this.org,
    required this.type,
    required this.district,
    required this.location,
    required this.money,
    required this.deadline,
    required this.urgent,
    required this.about,
    required this.eligibility,
    required this.applyInfo,
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'],
      title: json['title'],
      org: json['org'],
      type: json['type'],
      district: json['district'],
      location: json['location'],
      money: json['money'],
      deadline: json['deadline'],
      urgent: json['urgent'],
      about: json['about'],
      eligibility: List<String>.from(json['eligibility']),
      applyInfo: json['applyInfo'],
    );
  }
}