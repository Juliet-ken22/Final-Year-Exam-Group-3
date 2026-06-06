import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  final void Function(String category)? onCategorySelected;
  const CategoryChips({super.key, this.onCategorySelected});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  int _selected = 0;

  final List<_Category> _categories = [
    _Category(label: 'All', icon: Icons.apps_rounded),
    _Category(label: 'Protein', icon: Icons.fitness_center_rounded),
    _Category(label: 'Vitamins', icon: Icons.local_pharmacy_outlined),
    _Category(label: 'Superfoods', icon: Icons.eco_rounded),
    _Category(label: 'Omega-3', icon: Icons.water_drop_outlined),
    _Category(label: 'Probiotics', icon: Icons.spa_rounded),
    _Category(label: 'Bundles', icon: Icons.inventory_2_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == _selected;
          return GestureDetector(
            onTap: () {
              setState(() => _selected = i);
              widget.onCategorySelected?.call(_categories[i].label);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2E7D32) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFE0E0E0),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _categories[i].icon,
                    size: 14,
                    color: selected ? Colors.white : const Color(0xFF888888),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _categories[i].label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  const _Category({required this.label, required this.icon});
}