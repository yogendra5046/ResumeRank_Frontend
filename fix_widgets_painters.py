import os

def fix_career_radar():
    path = 'lib/widgets/career_radar_widget.dart'
    if not os.path.exists(path):
        return
        
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Replace CareerRadarWidget implementation
    old_widget = """class CareerRadarWidget extends StatelessWidget {
  final List<Map<String, dynamic>> skills; // [{name: str, value: double}]
  final double size;

  const CareerRadarWidget({super.key, required this.skills, this.size = 250});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _RadarPainter(skills: skills)),
    );
  }
}"""

    new_widget = """class CareerRadarWidget extends StatelessWidget {
  final List<Map<String, dynamic>> skills; // [{name: str, value: double}]
  final double size;

  const CareerRadarWidget({super.key, required this.skills, this.size = 250});

  @override
  Widget build(BuildContext context) {
    final labelColor = Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? const Color(0xFF64748B);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _RadarPainter(skills: skills, labelColor: labelColor)),
    );
  }
}"""

    # Replace _RadarPainter implementation
    old_painter = """class _RadarPainter extends CustomPainter {
  final List<Map<String, dynamic>> skills;

  _RadarPainter({required this.skills});"""

    new_painter = """class _RadarPainter extends CustomPainter {
  final List<Map<String, dynamic>> skills;
  final Color labelColor;

  _RadarPainter({required this.skills, required this.labelColor});"""

    content = content.replace(old_widget, new_widget)
    content = content.replace(old_painter, new_painter)
    
    # Replace label paint usage
    content = content.replace(
        "color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? const Color(0xFF64748B),",
        "color: labelColor,"
    )
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed career_radar_widget.dart")

def main():
    fix_career_radar()

if __name__ == '__main__':
    main()
