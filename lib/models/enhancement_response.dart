class EnhancementResponse {
  final String rewrittenText;
  final List<String> detailedEnhancements;
  final List<SkillRoute> skillRouteMap;
  final int tokensUsed;

  EnhancementResponse({
    required this.rewrittenText,
    required this.detailedEnhancements,
    required this.skillRouteMap,
    required this.tokensUsed,
  });

  factory EnhancementResponse.fromJson(Map<String, dynamic> json) {
    return EnhancementResponse(
      rewrittenText: json['rewritten_text'] ?? '',
      detailedEnhancements: List<String>.from(
        json['detailed_enhancements'] ?? [],
      ),
      skillRouteMap: (json['skill_route_map'] as List? ?? [])
          .map((item) => SkillRoute.fromJson(item))
          .toList(),
      tokensUsed: json['tokens_used'] ?? 0,
    );
  }
}

class SkillRoute {
  final String skill;
  final String path;
  final String project;
  final String time;
  final String url;

  SkillRoute({
    required this.skill,
    required this.path,
    required this.project,
    required this.time,
    required this.url,
  });

  factory SkillRoute.fromJson(Map<String, dynamic> json) {
    return SkillRoute(
      skill: json['skill'] ?? '',
      path: json['path'] ?? '',
      project: json['project'] ?? '',
      time: json['time'] ?? '',
      url: json['url'] ?? 'https://www.google.com',
    );
  }
}
