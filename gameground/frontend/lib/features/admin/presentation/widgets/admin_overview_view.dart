import 'package:flutter/material.dart';

class AdminOverviewView extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final VoidCallback onRefresh;

  const AdminOverviewView({
    super.key,
    required this.stats,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 1200;
    final isMedium = MediaQuery.of(context).size.width > 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Overview',
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'High-level insights and statistics',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: isWide ? 3 : (isMedium ? 2 : 1),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isWide ? 2.4 : 2.0,
            children: [
              _buildStatCard('Total Players', '${stats?['totalPlayers'] ?? 0}', Icons.people, Colors.blue, colorScheme, textTheme),
              _buildStatCard('Venue Owners', '${stats?['totalVenueOwners'] ?? 0}', Icons.manage_accounts, Colors.indigo, colorScheme, textTheme),
              _buildStatCard('Listed Venues', '${stats?['totalVenues'] ?? 0}', Icons.stadium, Colors.orange, colorScheme, textTheme),
              _buildStatCard('Total Revenue', '₹${stats?['totalSubscriptionRevenue'] ?? 0}', Icons.payments, Colors.deepPurple, colorScheme, textTheme),
              _buildStatCard('Turf Bookings', '${stats?['totalVenueBookings'] ?? 0}', Icons.calendar_month, Colors.green, colorScheme, textTheme),
              _buildStatCard('Coach Bookings', '${stats?['totalCoachingBookings'] ?? 0}', Icons.sports, Colors.teal, colorScheme, textTheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color accentColor, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
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
