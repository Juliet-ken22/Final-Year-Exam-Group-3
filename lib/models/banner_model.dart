import 'package:flutter/material.dart';

class PromoBanner {
  final String tag;
  final String title;
  final String subtitle;
  final String ctaText;
  final Color bgColor;
  final Color accentColor;
  final IconData icon;

  const PromoBanner({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.bgColor,
    required this.accentColor,
    required this.icon,
  });
}

final List<PromoBanner> sampleBanners = [
  PromoBanner(
    tag: 'FLASH SALE',
    title: 'Protein\nWeek 🏋️',
    subtitle: '30% off all whey\n& protein products',
    ctaText: 'Shop Now',
    bgColor: const Color(0xFF1B4332),
    accentColor: const Color(0xFF4CAF50),
    icon: Icons.fitness_center_rounded,
  ),
  PromoBanner(
    tag: 'NEW ARRIVALS',
    title: 'Superfood\nBlends 🌿',
    subtitle: 'Just landed in\nour store',
    ctaText: 'Explore',
    bgColor: const Color(0xFF1A237E),
    accentColor: const Color(0xFF5C6BC0),
    icon: Icons.eco_rounded,
  ),
  PromoBanner(
    tag: 'FREE DELIVERY',
    title: 'Orders Over\nUGX 50K 🚚',
    subtitle: 'Fast & reliable\ndelivery to you',
    ctaText: 'Order Now',
    bgColor: const Color(0xFF4A148C),
    accentColor: const Color(0xFF9C27B0),
    icon: Icons.local_shipping_rounded,
  ),
  PromoBanner(
    tag: 'BUNDLE DEAL',
    title: 'Meal Plan\nBundle 🥗',
    subtitle: 'Save 25% on\nweekly bundles',
    ctaText: 'View Bundle',
    bgColor: const Color(0xFFBF360C),
    accentColor: const Color(0xFFFF7043),
    icon: Icons.restaurant_menu_rounded,
  ),
];