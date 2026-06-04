import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import '../models/job_application.dart';
import '../models/job_application_adapter.dart';
import '../core/di/injection_container.dart';

class JobService {
  static const String boxName = 'job_applications';

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(JobApplicationAdapter());
    }
    await Hive.openBox<JobApplication>(boxName);
  }

  static Box<JobApplication> get _box {
    return Hive.box<JobApplication>(boxName);
  }

  static Future<void> syncFromCloud() async {
    try {
      final dio = sl<Dio>();
      final response = await dio.get('/jobs/');
      if (response.statusCode == 200) {
        await _box.clear();
        final List<dynamic> data = response.data;
        for (var item in data) {
           final job = JobApplication(
             id: item['id'],
             companyName: item['company_name'],
             jobTitle: item['job_title'],
             appliedDate: DateTime.parse(item['applied_date']),
             status: item['status'],
             notes: item['notes'],
           );
           await _box.put(job.id, job);
        }
      }
    } catch(e) {
      // ignore
    }
  }

  static Future<void> _pushToCloud(JobApplication job) async {
    try {
      final dio = sl<Dio>();
      await dio.post('/jobs/', data: {
        'id': job.id,
        'company_name': job.companyName,
        'job_title': job.jobTitle,
        'applied_date': job.appliedDate.toIso8601String(),
        'status': job.status,
        'notes': job.notes,
      });
    } catch(e) {
      // ignore
    }
  }

  static Future<void> addJob(JobApplication job) async {
    await _box.put(job.id, job);
    await _pushToCloud(job);
  }

  static List<JobApplication> getAllJobs() {
    return _box.values.toList()
      ..sort((a, b) => b.appliedDate.compareTo(a.appliedDate));
  }

  static Future<void> deleteJob(String id) async {
    await _box.delete(id);
    try {
      final dio = sl<Dio>();
      await dio.delete('/jobs/$id');
    } catch(e) {
      // ignore
    }
  }

  static Future<void> updateJob(JobApplication job) async {
    await _box.put(job.id, job);
    await _pushToCloud(job);
  }
}
