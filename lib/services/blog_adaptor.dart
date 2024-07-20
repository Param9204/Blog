// blog_adapter.dart
import 'package:hive/hive.dart';
import 'package:blog/models/blog.dart';

class BlogAdapter extends TypeAdapter<Blog> {
  @override
  final typeId = 0;

  @override
  Blog read(BinaryReader reader) {
    return Blog(
      id: reader.readString(),
      title: reader.readString(),
      content: reader.readString(),
      authorId: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()), // Updated line
      categories: reader.readList().cast<String>(),
      tags: reader.readList().cast<String>(),
      imageUrl: reader.readString(),
      authorEmail: reader.readString(),
      likes: reader.readInt(),
      dislikes: reader.readInt(),
      likedBy: reader.readList().cast<String>(),
      dislikedBy: reader.readList().cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Blog obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.content);
    writer.writeString(obj.authorId);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch); // Updated line
    writer.writeList(obj.categories);
    writer.writeList(obj.tags);
    writer.writeString(obj.imageUrl);
    writer.writeString(obj.authorEmail);
    writer.writeInt(obj.likes);
    writer.writeInt(obj.dislikes);
    writer.writeList(obj.likedBy);
    writer.writeList(obj.dislikedBy);
  }
}
