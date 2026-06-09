import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../orders/orders_screen.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);
const _border = Color(0xFFE0E0E0);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data') ?? '{}';
    try {
      final user = jsonDecode(userJson);
      if (!mounted) return;
      setState(() {
        _firstName = user['first_name'] ?? user['name']?.split(' ').first ?? '';
        _lastName = user['last_name'] ?? '';
        _email = user['email'] ?? '';
        _phone = user['phone'] ?? '';
      });
    } catch (_) {}
  }

  String get _fullName => '$_firstName $_lastName'.trim();
  String get _initials {
    final f = _firstName.isNotEmpty ? _firstName[0] : '';
    final l = _lastName.isNotEmpty ? _lastName[0] : '';
    return '$f$l'.toUpperCase().isEmpty ? '?' : '$f$l'.toUpperCase();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: _textLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    setState(() => _isLoggingOut = true);
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ No Scaffold — MainNavigationScreen owns it
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────
            _buildHeader(),

            const SizedBox(height: 20),

            // ── Menu Items ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Account'),
                  const SizedBox(height: 10),
                  _buildMenuCard([
                    _MenuItem(Icons.person_outline_rounded, 'Edit Profile',
                        'Update your info',
                        onTap: () => _showEditProfile()),
                    _MenuItem(Icons.lock_outline_rounded, 'Change Password',
                        'Update your password',
                        onTap: () {}),
                    _MenuItem(Icons.location_on_outlined, 'Saved Addresses',
                        'Manage delivery addresses',
                        onTap: () {}),
                  ]),

                  const SizedBox(height: 20),
                  _sectionLabel('Orders'),
                  const SizedBox(height: 10),
                  _buildMenuCard([
                    _MenuItem(Icons.receipt_long_outlined, 'My Orders',
                        'Track your purchases',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const OrdersScreen()))),
                    _MenuItem(Icons.favorite_border_rounded, 'Wishlist',
                        'Your saved products',
                        onTap: () {}),
                  ]),

                  const SizedBox(height: 20),
                  _sectionLabel('Support'),
                  const SizedBox(height: 10),
                  _buildMenuCard([
                    _MenuItem(Icons.help_outline_rounded, 'Help & FAQ',
                        'Get help and answers',
                        onTap: () {}),
                    _MenuItem(Icons.support_agent_rounded, 'Contact Us',
                        'Reach our support team',
                        onTap: () {}),
                    _MenuItem(Icons.info_outline_rounded, 'About NutriBlend',
                        'App version 1.0.0',
                        onTap: () {}),
                  ]),

                  const SizedBox(height: 20),
                  _sectionLabel('Legal'),
                  const SizedBox(height: 10),
                  _buildMenuCard([
                    _MenuItem(Icons.description_outlined, 'Terms of Service',
                        '',
                        onTap: () {}),
                    _MenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', '',
                        onTap: () {}),
                  ]),

                  const SizedBox(height: 24),

                  // ── Logout Button ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _isLoggingOut ? null : _handleLogout,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFD32F2F), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        foregroundColor: const Color(0xFFD32F2F),
                      ),
                      child: _isLoggingOut
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFD32F2F)))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Log Out',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Center(
                    child: Text('NutriBlend v1.0.0',
                        style: TextStyle(fontSize: 12, color: _textLight)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        children: [
          // Top row
          Row(
            children: [
              const SizedBox(width: 42),
              const Expanded(
                child: Text('My Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              GestureDetector(
                onTap: _showEditProfile,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      size: 18, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: Center(
              child: Text(_initials,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),

          const SizedBox(height: 12),

          Text(_fullName.isEmpty ? 'NutriBlend User' : _fullName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 4),
          if (_email.isNotEmpty)
            Text(_email,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8))),
          if (_phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(_phone,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7))),
          ],
        ],
      ),
    );
  }

  // ─── Menu Card ────────────────────────────────────────────────────────────

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.5),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: _primary, size: 20),
                ),
                title: Text(item.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textDark)),
                subtitle: item.subtitle.isNotEmpty
                    ? Text(item.subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: _textLight))
                    : null,
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: _textLight),
              ),
              if (!isLast)
                const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFF0F0F0)),
            ],
          );
        }),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textLight,
            letterSpacing: 0.5));
  }

  // ─── Edit Profile Bottom Sheet ────────────────────────────────────────────

  void _showEditProfile() {
    final firstCtrl = TextEditingController(text: _firstName);
    final lastCtrl = TextEditingController(text: _lastName);
    final phoneCtrl = TextEditingController(text: _phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textDark)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _sheetField(
                        firstCtrl, 'First Name', Icons.person_outline_rounded)),
                const SizedBox(width: 12),
                Expanded(
                    child: _sheetField(
                        lastCtrl, 'Last Name', Icons.person_outline_rounded)),
              ],
            ),
            const SizedBox(height: 14),
            _sheetField(phoneCtrl, 'Phone Number', Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _firstName = firstCtrl.text.trim();
                    _lastName = lastCtrl.text.trim();
                    _phone = phoneCtrl.text.trim();
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Changes',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetField(
      TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textDark)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: _textDark),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: _textLight),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: _border, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: _primary, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.title, this.subtitle,
      {required this.onTap});
}