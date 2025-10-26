class EventModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final String location;
  final String createdBy;
  final String ownerName;
  final String code;
  final List<dynamic> participants;
  final List<dynamic> photos;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.createdBy,
    required this.ownerName,
    required this.participants,
    required this.photos,
    required this.code,
  });

  factory EventModel.fromMap(String id, Map data) {
    return EventModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] ?? '',
      location: data['location'] ?? '',
      createdBy: data['createdBy'] ?? '',
      ownerName: data['ownerName'] ?? '',
      code: data['code'] ?? '',
      participants: List.from(data['participants'] ?? []),
      photos: List<String>.from(data['photos'] ?? []),
    );
  }
}
