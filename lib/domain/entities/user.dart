class User {
  final String id;
  final String firstName;
  final String lastName;
  final String pictureUrl;
  final int age;
  final String city;
  final String country;
  bool isLiked;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.pictureUrl,
    required this.age,
    required this.city,
    required this.country,
    this.isLiked = false,
  });

  String get fullName => '$firstName $lastName';
}


