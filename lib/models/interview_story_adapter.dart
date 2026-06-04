import 'package:hive/hive.dart';
import 'interview_story.dart';

class InterviewStoryAdapter extends TypeAdapter<InterviewStory> {
  @override
  final int typeId = 2;

  @override
  InterviewStory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterviewStory(
      id: fields[0] as String,
      title: fields[1] as String,
      situation: fields[2] as String,
      task: fields[3] as String,
      action: fields[4] as String,
      result: fields[5] as String,
      lastModified: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InterviewStory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.situation)
      ..writeByte(3)
      ..write(obj.task)
      ..writeByte(4)
      ..write(obj.action)
      ..writeByte(5)
      ..write(obj.result)
      ..writeByte(6)
      ..write(obj.lastModified);
  }
}
