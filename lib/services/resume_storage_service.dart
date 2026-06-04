import 'package:file_picker/file_picker.dart';

class ResumeStorageService {
  static final ResumeStorageService _instance = ResumeStorageService._internal();
  factory ResumeStorageService() => _instance;
  ResumeStorageService._internal();

  PlatformFile? activeResume;

  bool get hasResume => activeResume != null;

  void setResume(PlatformFile file) {
    activeResume = file;
  }
  
  void clearResume() {
    activeResume = null;
  }
}
