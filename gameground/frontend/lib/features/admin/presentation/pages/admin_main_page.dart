import 'package:flutter/material.dart';
import 'package:frontend/features/admin/presentation/pages/admin_dashboard_page.dart';

class AdminMainPage extends StatelessWidget {
  const AdminMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We now use AdminDashboardPage as the main modular entry point
    return const AdminDashboardPage();
  }
}
