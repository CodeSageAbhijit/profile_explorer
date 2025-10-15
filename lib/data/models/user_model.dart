import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String pictureUrl,
    required int age,
    required String city,
    required String country,
    bool isLiked = false,
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          pictureUrl: pictureUrl,
          age: age,
          city: city,
          country: country,
          isLiked: isLiked,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['login']['uuid'],
      firstName: json['name']['first'],
      lastName: json['name']['last'],
      pictureUrl: json['picture']['large'],
      age: json['dob']['age'],
      city: json['location']['city'],
      country: json['location']['country'],
    );
  }
}


