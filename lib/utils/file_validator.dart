import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileValidator {
  /// Validates the picked file for PDF format and size limits.
  /// Returns a [String] error message if invalid, or [null] if valid.
  static String? validateFile(PlatformFile? file) {
    if (file == null) {
      return "Please select a file";
    }

    // Check file extension
    final extension = file.extension?.toLowerCase();
    if (extension != 'pdf') {
      return "Only PDF files are allowed";
    }

    // Check file size (10MB limit)
    // file.size is in bytes
    const maxSizeBytes = 10 * 1024 * 1024; // 10MB
    if (file.size > maxSizeBytes) {
      return "File too large. Max 10MB allowed";
    }

    return null;
  }

  /// Shows a user-friendly error SnackBar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}
