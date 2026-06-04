import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_profile.dart';

class ResumeExportService {
  static Future<void> generateAndShare(UserProfile profile) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(profile),
          pw.SizedBox(height: 20),
          _buildSectionTitle("PROFESSIONAL SUMMARY"),
          pw.Paragraph(
            text: profile.bio,
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 15),
          _buildSectionTitle("EXPERIENCE"),
          ...profile.experience.map((e) => _buildExperienceItem(e)),
          pw.SizedBox(height: 15),
          _buildSectionTitle("EDUCATION"),
          ...profile.education.map((e) => _buildEducationItem(e)),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      "${output.path}/Resume_${profile.name.replaceAll(' ', '_')}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'My ATS-Optimized Resume');
  }

  static pw.Widget _buildHeader(UserProfile profile) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          profile.name.toUpperCase(),
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          profile.role,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          "Target: ${profile.targetSalary} | ${profile.workPreference}",
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildExperienceItem(ExperienceItem item) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                item.role,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.Text(item.period, style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
          pw.Text(
            item.company,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.blue700),
          ),
          pw.SizedBox(height: 4),
          pw.Bullet(
            text: item.description,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildEducationItem(EducationItem item) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                item.degree,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.Text(item.year, style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
          pw.Text(item.institution, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
