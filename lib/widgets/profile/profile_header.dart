import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              'https://via.placeholder.com/150',
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Maria',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 4),

          const Text(
            'maria@email.com',
          ),
        ],
      ),
    );
  }
}