class RewriteResponse {
  final String rewrittenText;
  final int tokensUsed;

  RewriteResponse({required this.rewrittenText, required this.tokensUsed});

  factory RewriteResponse.fromJson(Map<String, dynamic> json) {
    return RewriteResponse(
      rewrittenText: json['rewritten_text'] as String? ?? '',
      tokensUsed: json['tokens_used'] as int? ?? 0,
    );
  }
}
