class ListItem {
  int? id;
  String title;
  String description;

  ListItem({
    this.id,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  static ListItem fromMap(Map<String, dynamic> map) {
    return ListItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
    );
  }
}
