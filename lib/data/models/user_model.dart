class UserModel {
  final String id;
  final String name;
  final String phonenumber;
  final String? photo;
  final DateTime lastSeen;
  final DateTime created_at;

  UserModel({
    required this.id,
    required this.name,
    required this.phonenumber,
    this.photo,
    required this.lastSeen,
    required this.created_at,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'] ?? '',
      name: map['name'] ?? '',
      phonenumber: map['phonenumber'] ?? '',
      photo: map['photo'],
      lastSeen: map['lastSeen'] != null ? DateTime.parse(map['lastSeen']) : DateTime.now(),
      created_at: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'name': name,
      'phonenumber': phonenumber,
      'photo': photo,
      'lastSeen': lastSeen.toIso8601String(),
      'created_at': created_at.toIso8601String(),
    };
  }
}
