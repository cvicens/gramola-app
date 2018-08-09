class Event {
  final int id;
  final String name;
  final String date;
  final String location;
  final String artist;
  final String description;
  final String image;


  const Event({this.id, this.name, this.date, this.location, this.artist,
    this.description, this.image});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id:          json['id'],
      name:        json['name'],
      date:        json['date'],
      location:    json['location'],
      artist:      json['artist'],
      description: json['description'],
      image:       json['image'],
    );
  }
}