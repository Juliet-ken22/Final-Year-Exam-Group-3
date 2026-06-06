import 'package:flutter/material.dart';

const _tips = [
  _Tip(
    icon: Icons.fitness_center_rounded,
    title: 'Post-Workout Tip',
    body: 'Whey protein absorbs fastest post-workout. Take within 30 minutes for best results.',
    color: Color(0xFF1B4332),
  ),
  _Tip(
    icon: Icons.wb_sunny_outlined,
    title: 'Morning Routine',
    body: 'Taking Omega-3 with breakfast improves absorption by up to 50%.',
    color: Color(0xFF1A237E),
  ),
  _Tip(
    icon: Icons.bedtime_outlined,
    title: 'Sleep & Recovery',
    body: 'Magnesium taken before bed supports muscle recovery and deeper sleep.',
    color: Color(0xFF4A148C),
  ),
];

class NutritionTipBanner extends StatefulWidget {
  const NutritionTipBanner({super.key});

  @override
  State<NutritionTipBanner> createState() => _NutritionTipBannerState();
}

class _NutritionTipBannerState extends State<NutritionTipBanner> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tip = _tips[_index];
    return GestureDetector(
      onTap: () => setState(() => _index = (_index + 1) % _tips.length),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tip.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tip.color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tip.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tip.icon, color: tip.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '💡 ${tip.title}',
                        style: TextStyle(
                          color: tip.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Tap for more',
                        style: TextStyle(
                          color: tip.color.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tip.body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF555555),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tip {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _Tip({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });
}