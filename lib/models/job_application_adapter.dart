import 'package:hive/hive.dart';
import 'job_application.dart';

class JobApplicationAdapter extends TypeAdapter<JobApplication> {
  @override
  final int typeId = 1;

  @override
  JobApplication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobApplication(
      id: fields[0] as String,
      companyName: fields[1] as String,
      jobTitle: fields[2] as String,
      appliedDate: fields[3] as DateTime,
      status: fields[4] as String,
      url: fields[5] as String?,
      notes: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, JobApplication obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.companyName)
      ..writeByte(2)
      ..write(obj.jobTitle)
      ..writeByte(3)
      ..write(obj.appliedDate)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.url)
      ..writeByte(6)
      ..write(obj.notes);
  }
}
