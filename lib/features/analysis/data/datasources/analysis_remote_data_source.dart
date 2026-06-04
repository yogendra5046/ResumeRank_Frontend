import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/analysis_result_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AnalysisRemoteDataSource {
  Future<AnalysisResultModel> analyzeResume({
    required PlatformFile resumeFile,
    required String jdText,
  });

  Future<Map<String, dynamic>> compareMultiple({
    required List<PlatformFile> files,
    required String jdText,
  });

  Future<Map<String, dynamic>> getJobMatches({
    required PlatformFile resumeFile,
  });

  Future<Map<String, dynamic>> getMarketInsights();
}

class AnalysisRemoteDataSourceImpl implements AnalysisRemoteDataSource {
  final Dio dio;

  AnalysisRemoteDataSourceImpl({required this.dio});

  @override
  Future<AnalysisResultModel> analyzeResume({
    required PlatformFile resumeFile,
    required String jdText,
  }) async {
    try {
      MultipartFile filePart;

      if (kIsWeb) {
        if (resumeFile.bytes == null) {
          throw ServerException("Web upload failed: File bytes are null");
        }
        filePart = MultipartFile.fromBytes(
          resumeFile.bytes!,
          filename: resumeFile.name,
        );
      } else {
        if (resumeFile.path == null) {
          throw ServerException("Mobile upload failed: File path is null");
        }
        filePart = await MultipartFile.fromFile(
          resumeFile.path!,
          filename: resumeFile.name,
        );
      }

      final formData = FormData.fromMap({
        'resume': filePart,
        'jd_text': jdText,
      });

      final response = await dio.post('/analyze', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AnalysisResultModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          response.data['detail'] ?? 'Failed to analyze resume',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> compareMultiple({
    required List<PlatformFile> files,
    required String jdText,
  }) async {
    try {
      List<MultipartFile> fileParts = [];

      for (var file in files) {
        if (kIsWeb) {
          if (file.bytes == null) throw ServerException("Web upload failed");
          fileParts.add(
            MultipartFile.fromBytes(file.bytes!, filename: file.name),
          );
        } else {
          if (file.path == null) throw ServerException("Mobile upload failed");
          fileParts.add(
            await MultipartFile.fromFile(file.path!, filename: file.name),
          );
        }
      }

      final formData = FormData.fromMap({
        'files': fileParts,
        'jd_text': jdText,
      });

      final response = await dio.post('/compare-multiple', data: formData);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          response.data['detail'] ?? 'Failed to compare resumes',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getJobMatches({
    required PlatformFile resumeFile,
  }) async {
    try {
      MultipartFile filePart;
      if (kIsWeb) {
        if (resumeFile.bytes == null)
          throw ServerException("Web upload failed");
        filePart = MultipartFile.fromBytes(
          resumeFile.bytes!,
          filename: resumeFile.name,
        );
      } else {
        if (resumeFile.path == null)
          throw ServerException("Mobile upload failed");
        filePart = await MultipartFile.fromFile(
          resumeFile.path!,
          filename: resumeFile.name,
        );
      }

      final formData = FormData.fromMap({'resume': filePart});
      final response = await dio.post('/job-matches', data: formData);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          response.data['detail'] ?? 'Failed to get job matches',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getMarketInsights() async {
    try {
      final response = await dio.get('/insights/market');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          response.data['detail'] ?? 'Failed to fetch market insights',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
