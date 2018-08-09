class Subject {
  final String userId;
  final String token;

  Subject({this.userId, this.token});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      userId: json['userId'],
      token: json['token']
    );
  }
}