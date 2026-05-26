class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final String? profileImageUrl;
  final String? about;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    this.profileImageUrl,
    this.about,
    this.isOnline = false,
    required this.lastSeen,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      about: map['about'] ?? 'Hey there! I am using DTN Chat',
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null ? DateTime.parse(map['lastSeen']) : DateTime.now(),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'about': about ?? 'Hey there! I am using DTN Chat',
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    String? about,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      about: about ?? this.about,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
