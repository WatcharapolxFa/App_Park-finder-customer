class Profile {
  Profile({
    required this.profileID,
    required this.birthDay,
    required this.cashback,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.point,
    required this.profilePictureURL,
    required this.ssn,
  });
  final String profileID;
  final String birthDay;
  final int cashback;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final int point;
  final String profilePictureURL;
  final String ssn;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      profileID: json['_id'],
      birthDay: json['birth_day'],
      cashback: json['cashback'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      point: json['point'],
      profilePictureURL: json['profile_picture_url'],
      ssn: json['ssn'],
    );
  }
}
