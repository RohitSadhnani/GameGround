import 'package:flutter/material.dart';
import 'package:frontend/features/admin/data/admin_service.dart';
import 'package:frontend/features/admin/presentation/widgets/admin_sidebar.dart';
import 'package:frontend/features/admin/presentation/widgets/admin_overview_view.dart';
import 'package:frontend/features/admin/presentation/widgets/admin_management_view.dart';
import 'package:frontend/features/admin/presentation/widgets/admin_reports_view.dart';
import 'package:frontend/core/utils/url_helper.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _updateUrl(); // Set initial URL
  }

  void _updateUrl() {
    switch (_selectedIndex) {
      case 0:
        updateBrowserUrl('/admin/overview', title: 'Admin - Overview | GameGround');
        break;
      case 1:
        updateBrowserUrl('/admin/management', title: 'Admin - Management | GameGround');
        break;
      case 2:
        updateBrowserUrl('/admin/reports', title: 'Admin - Reports | GameGround');
        break;
      default:
        updateBrowserUrl('/admin', title: 'Admin Console | GameGround');
    }
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await AdminService.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stats: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      // We only show the standard AppBar on mobile
      appBar: isWide ? null : AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Row(
            children: [
              if (isWide)
                AdminSidebar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _updateUrl();
                    });
                  },
                ),
              Expanded(
                child: Container(
                  color: colorScheme.background,
                  child: _buildCurrentView(),
                ),
              ),
            ],
          ),
      // Mobile Navigation
      bottomNavigationBar: !isWide ? NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
            _updateUrl();
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.manage_accounts), label: 'Manage'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Reports'),
        ],
      ) : null,
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 0:
        return AdminOverviewView(stats: _stats, onRefresh: _loadStats);
      case 1:
        return AdminManagementView(stats: _stats);
      case 2:
        return AdminReportsView();
      default:
        return AdminOverviewView(stats: _stats, onRefresh: _loadStats);
    }
  }
}
