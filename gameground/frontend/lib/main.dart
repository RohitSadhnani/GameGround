import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/venue/presentation/pages/venue_owner_dashboard_page.dart';
import 'features/admin/presentation/pages/admin_main_page.dart';
import 'features/auth/data/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  runApp(const VenueBookingApp());
}

class VenueBookingApp extends StatelessWidget {
  const VenueBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameGround',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: AuthService.token != null 
          ? (AuthService.role == 'admin' 
              ? const AdminMainPage() 
              : (AuthService.role == 'venue_owner' ? const VenueOwnerDashboardPage() : const DashboardPage())) 
          : const LoginPage(),
    );
  }
}
