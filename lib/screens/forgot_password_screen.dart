import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String? _devOtp;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://resumerankappbackend-production.up.railway.app/v1'));

  Future<void> _requestOtp() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final res = await _dio.post('/auth/forgot-password',
          data: {'email': _emailCtrl.text.trim()});
      setState(() {
        _otpSent = true;
        _devOtp = res.data['dev_otp'];
      });
    } catch (_) {
      _snack('Could not send OTP. Check your email.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_otpCtrl.text.isEmpty || _newPassCtrl.text.isEmpty) {
      _snack('Please fill all fields.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _dio.post('/auth/reset-password', data: {
        'email': _emailCtrl.text.trim(),
        'otp': _otpCtrl.text.trim(),
        'new_password': _newPassCtrl.text.trim(),
      });
      if (mounted) {
        _snack('Password reset! Please log in.');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on DioException catch (e) {
      _snack(e.response?.data?['detail'] ?? 'Reset failed.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.lock_reset_rounded,
                      size: 48, color: AppColors.primary),
                ),
                SizedBox(height: 24),
                Text('Reset Password',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w900))
                    .animate()
                    .fadeIn(),
                SizedBox(height: 8),
                Text(
                  _otpSent
                      ? 'Enter the OTP and your new password.'
                      : 'Enter your email to receive a 6-digit reset OTP.',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 14),
                ),
                SizedBox(height: 36),
                _label('EMAIL'),
                SizedBox(height: 8),
                TextField(
                  controller: _emailCtrl,
                  enabled: !_otpSent,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _input(Icons.email_outlined, 'your@email.com'),
                ),
                if (!_otpSent) ...[
                  SizedBox(height: 32),
                  _btn('Send Reset OTP', _requestOtp),
                ],
                if (_otpSent) ...[
                  SizedBox(height: 20),
                  if (_devOtp != null)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppColors.warning, size: 16),
                        SizedBox(width: 8),
                        Text('Dev OTP: $_devOtp',
                            style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold)),
                      ]),
                    ).animate().fadeIn(),
                  SizedBox(height: 20),
                  _label('OTP CODE'),
                  SizedBox(height: 8),
                  TextField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: _input(Icons.pin_rounded, '6-digit OTP'),
                  ),
                  SizedBox(height: 16),
                  _label('NEW PASSWORD'),
                  SizedBox(height: 8),
                  TextField(
                    controller: _newPassCtrl,
                    obscureText: true,
                    decoration: _input(Icons.lock_outline, 'New password'),
                  ),
                  SizedBox(height: 32),
                  _btn('Reset Password', _resetPassword),
                  SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _otpSent = false),
                      child: Text('Use a different email',
                          style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                ],
                SizedBox(height: 40),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          color: AppColors.primary));

  InputDecoration _input(IconData icon, String hint) => InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        hintText: hint,
        hintStyle:
            TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 14),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        counterText: '',
        contentPadding: EdgeInsets.symmetric(vertical: 18),
      );

  Widget _btn(String label, VoidCallback fn) => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
            onPressed: _isLoading ? null : fn,
            child: Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900))),
      ).animate().fadeIn();
}
