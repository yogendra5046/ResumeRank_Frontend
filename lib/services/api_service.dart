import 'dart:async';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/analysis_result.dart';
import '../models/enhancement_response.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
      headers: {
        'Accept': 'application/json',
        'X-API-Key': 'resumerank-pro-2026',
      },
    ),
  );

  Future<String> _getBaseUrl() async {
    return 'https://resumerankappbackend-production.up.railway.app/v1';
  }

  Future<AnalysisResult> analyzeResume({
    required PlatformFile resumeFile,
    required String jdText,
    int retryCount = 0,
  }) async {
    final baseUrl = await _getBaseUrl();
    final fullUrl = '$baseUrl/analyze';

    try {
      MultipartFile filePart;

      if (kIsWeb) {
        if (resumeFile.bytes == null) {
          throw Exception("Web upload failed: File bytes are null");
        }
        filePart = MultipartFile.fromBytes(
          resumeFile.bytes!,
          filename: resumeFile.name,
        );
      } else {
        if (resumeFile.path == null) {
          throw Exception("Mobile upload failed: File path is null");
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

      // Uploading file

      final response = await _dio.post(
        fullUrl,
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            debugPrint(
              "📤 Uploading: ${(sent / total * 100).toStringAsFixed(0)}%",
            );
          }
        },
      );
      // Log response status internally if needed

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AnalysisResult.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.data['detail'] ?? 'Failed to analyze resume');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Timeout at $fullUrl. Is the backend running?");
      }
      final message =
          e.response?.data?['detail'] ??
          "Network Error [${e.response?.statusCode}]: ${e.message}";
      throw Exception(message);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  /// Compares multiple resumes against a job description
  Future<Map<String, dynamic>> compareMultiple({
    required List<PlatformFile> files,
    required String jdText,
  }) async {
    final baseUrl = await _getBaseUrl();

    try {
      List<MultipartFile> fileParts = [];

      for (var file in files) {
        if (kIsWeb) {
          if (file.bytes == null) {
            throw Exception(
              "Web upload failed: File bytes are null for ${file.name}",
            );
          }
          fileParts.add(
            MultipartFile.fromBytes(file.bytes!, filename: file.name),
          );
        } else {
          if (file.path == null) {
            throw Exception(
              "Upload failed: File path is null for ${file.name}",
            );
          }
          fileParts.add(
            await MultipartFile.fromFile(file.path!, filename: file.name),
          );
        }
      }

      final formData = FormData.fromMap({
        'files': fileParts,
        'jd_text': jdText,
      });

      final response = await _dio.post(
        '$baseUrl/compare-multiple',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['detail'] ?? 'Failed to compare resumes');
      }
    } catch (e) {
      throw Exception("Comparison failed: $e");
    }
  }

  /// Detailed AI enhancement for resume sections
  Future<EnhancementResponse> enhanceResume({
    required String resumeText,
    required String jdText,
    required List<String> missingSkills,
    required List<String> weakSections,
  }) async {
    final baseUrl = await _getBaseUrl();
    try {
      final response = await _dio.post(
        '$baseUrl/rewrite',
        data: {
          'resume_text': resumeText,
          'jd_text': jdText,
          'missing_skills': missingSkills,
          'weak_sections': weakSections,
        },
      );

      if (response.statusCode == 200) {
        return EnhancementResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception(response.data['detail'] ?? 'Failed to enhance resume');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? "AI Error: ${e.message}";
      throw Exception(message);
    } catch (e) {
      throw Exception("Enhancement failed: $e");
    }
  }

  /// Performs a deterministic rule-based audit
  Future<Map<String, dynamic>> getAuditReport({
    required String resumeText,
    required String jdText,
  }) async {
    final baseUrl = await _getBaseUrl();
    try {
      final response = await _dio.post(
        '$baseUrl/audit',
        data: {'resume_text': resumeText, 'jd_text': jdText},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['detail'] ?? 'Failed to perform audit');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? "Audit Error: ${e.message}";
      throw Exception(message);
    } catch (e) {
      throw Exception("Audit failed: $e");
    }
  }

  /// Finds matching job roles based on resume
  Future<Map<String, dynamic>> getJobMatches({
    required PlatformFile resumeFile,
  }) async {
    final baseUrl = await _getBaseUrl();
    try {
      MultipartFile filePart;
      if (kIsWeb) {
        if (resumeFile.bytes == null) throw Exception("Web upload failed");
        filePart = MultipartFile.fromBytes(
          resumeFile.bytes!,
          filename: resumeFile.name,
        );
      } else {
        if (resumeFile.path == null) throw Exception("Mobile upload failed");
        filePart = await MultipartFile.fromFile(
          resumeFile.path!,
          filename: resumeFile.name,
        );
      }

      final formData = FormData.fromMap({'resume': filePart});

      final response = await _dio.post('$baseUrl/job-matches', data: formData);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['detail'] ?? 'Failed to get job matches');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? "Job Match Error: ${e.message}";
      throw Exception(message);
    } catch (e) {
      throw Exception("Job matching failed: $e");
    }
  }

  /// Fetches live market trends and hot skills
  Future<Map<String, dynamic>> getMarketInsights() async {
    final baseUrl = await _getBaseUrl();
    try {
      final response = await _dio.get('$baseUrl/insights/market');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          response.data['detail'] ?? 'Failed to fetch market insights',
        );
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? "Market Insight Error: ${e.message}";
      throw Exception(message);
    } catch (e) {
      throw Exception("Market analysis failed: $e");
    }
  }
}
