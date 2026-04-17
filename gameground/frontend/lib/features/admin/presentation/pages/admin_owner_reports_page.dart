import 'package:flutter/material.dart';
import 'package:frontend/features/admin/data/admin_service.dart';

class AdminOwnerReportsPage extends StatefulWidget {
  const AdminOwnerReportsPage({super.key});

  @override
  State<AdminOwnerReportsPage> createState() => _AdminOwnerReportsPageState();
}

class _AdminOwnerReportsPageState extends State<AdminOwnerReportsPage> {
  bool _isLoadingOwners = true;
  List<dynamic> _owners = [];
  int? _selectedOwnerId;

  Map<String, dynamic>? _ownerStats;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _loadOwnersList();
  }

  Future<void> _loadOwnersList() async {
    final owners = await AdminService.getOwnersList();
    if (mounted) {
      setState(() {
        _owners = owners ?? [];
        _isLoadingOwners = false;
      });
    }
  }

  Future<void> _loadOwnerStats(int ownerId) async {
    setState(() => _isLoadingStats = true);
    final stats = await AdminService.getOwnerStats(ownerId);
    if (mounted) {
      setState(() {
        _ownerStats = stats;
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Performance'),
      ),
      body: _isLoadingOwners
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Select a Venue Owner',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(colorScheme, textTheme),
                  const SizedBox(height: 32),
                  if (_isLoadingStats)
                    const Center(child: CircularProgressIndicator())
                  else if (_ownerStats != null)
                    _buildStatsView(colorScheme, textTheme),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: const Text('Choose an owner to view stats'),
          value: _selectedOwnerId,
          items: _owners.map((owner) {
            return DropdownMenuItem<int>(
              value: owner['id'],
              child: Text('${owner['username']} (${owner['email']})', style: textTheme.bodyMedium),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedOwnerId = value);
              _loadOwnerStats(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatsView(ColorScheme colorScheme, TextTheme textTheme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance for ${_ownerStats!['username']}',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildReportCard(
                  'Total Venues Listed',
                  '${_ownerStats!['totalVenues']}',
                  Icons.stadium,
                  Colors.orange,
                  colorScheme,
                  textTheme
                ),
                const SizedBox(height: 12),
                _buildReportCard(
                  'Total Venue Bookings',
                  '${_ownerStats!['totalVenueBookings']}',
                  Icons.calendar_month,
                  Colors.green,
                   colorScheme,
                  textTheme
                ),
                 const SizedBox(height: 12),
                _buildReportCard(
                  'Total Coaching Bookings',
                  '${_ownerStats!['totalCoachingBookings']}',
                  Icons.sports,
                  Colors.teal,
                   colorScheme,
                  textTheme
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color accentColor, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      child: Padding(
         padding: const EdgeInsets.all(20),
         child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(value, style: textTheme.headlineMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
