class ConcisePost {
  final int id;
  final String title;
  final String summary;
  final DateTime activeDate;

  ConcisePost({
    this.id,
    this.title,
    this.summary,
    this.activeDate,
  });

  factory ConcisePost.fromJson(Map<String, dynamic> data) {
    final date = DateTime.parse(data['active_date']);

    return ConcisePost(
        id: data['id'],
        title: data['title'],
        summary: data['summary'],
        activeDate: DateTime(date.year, date.month, date.day));
  }
}

class Post extends ConcisePost {
  final String text;

  Post({int id, String title, String summary, DateTime activeDate, this.text})
      : super(id: id, title: title, summary: summary, activeDate: activeDate);

  factory Post.fromJson(Map<String, dynamic> data) {
    final concisePost = ConcisePost.fromJson(data);
    return Post(
        id: concisePost.id,
        title: concisePost.title,
        summary: concisePost.summary,
        activeDate: concisePost.activeDate,
        text: data['text']);
  }
}
