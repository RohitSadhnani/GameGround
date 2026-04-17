import 'package:flutter/material.dart';
import 'package:frontend/features/booking/presentation/pages/my_bookings_page.dart';
import 'package:frontend/features/booking/presentation/pages/my_coachings_page.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/data/auth_service.dart';
import 'package:frontend/features/profile/presentation/pages/owner_reports_page.dart';
import 'package:frontend/features/subscription/presentation/pages/subscription_details_page.dart';
import 'package:frontend/core/widgets/logout_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.person, size: 60, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Text(
                  AuthService.username ?? 'User',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  AuthService.email ?? 'No email',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (AuthService.role == 'user')
            _buildProfileItem(
              context,
              icon: Icons.history,
              title: 'My Bookings',
              textColor: colorScheme.onSurface,
              colorScheme: colorScheme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyBookingsPage()),
                );
              },
            ),
          if (AuthService.role == 'user')
            _buildProfileItem(
              context,
              icon: Icons.sports,
              title: 'My Coachings',
              textColor: colorScheme.onSurface,
              colorScheme: colorScheme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyCoachingsPage()),
                );
              },
            ),
          // Role-based visibility
          if (AuthService.role == 'venue_owner')
            _buildProfileItem(
              context,
              icon: Icons.bar_chart,
              title: 'View Reports',
              textColor: colorScheme.onSurface,
              colorScheme: colorScheme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OwnerReportsPage()),
                );
              },
              subtitle: 'Track your daily booked slots & revenue',
            ),
          if (AuthService.role == 'venue_owner')
            _buildProfileItem(
              context,
              icon: Icons.card_membership,
              title: 'Membership Details',
              textColor: colorScheme.onSurface,
              colorScheme: colorScheme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionDetailsPage()),
                );
              },
              subtitle: 'View plan, expiry date & renew pack',
            ),

          const SizedBox(height: 16),
          const Divider(indent: 20, endIndent: 20),
          const SizedBox(height: 8),
          _buildProfileItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            textColor: colorScheme.error,
            colorScheme: colorScheme,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => LogoutDialog(
                  onLogout: () async {
                    await AuthService.logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    Color? textColor,
    String? subtitle,
  }) {
    final textTheme = Theme.of(context).textTheme;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5), 
          shape: BoxShape.circle
        ),
        child: Icon(icon, color: textColor ?? colorScheme.primary),
      ),
      title: Text(
        title, 
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold, 
          color: textColor ?? colorScheme.onSurface
        )
      ),
      subtitle: subtitle != null 
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            ) 
          : null,
      trailing: Icon(Icons.chevron_right, size: 24, color: colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
