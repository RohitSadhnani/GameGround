import 'package:flutter/material.dart';
import 'package:frontend/features/admin/data/admin_service.dart';
import 'package:intl/intl.dart';

class ExpiringSubscriptionsPage extends StatefulWidget {
  const ExpiringSubscriptionsPage({super.key});

  @override
  State<ExpiringSubscriptionsPage> createState() => _ExpiringSubscriptionsPageState();
}

class _ExpiringSubscriptionsPageState extends State<ExpiringSubscriptionsPage> {
  bool _isLoading = true;
  List<dynamic>? _expiringSubscriptions;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchExpiringSubscriptions();
  }

  Future<void> _fetchExpiringSubscriptions() async {
    try {
      final subs = await AdminService.getExpiringSubscriptions();
      if (mounted) {
        setState(() {
          _expiringSubscriptions = subs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expiring Memberships'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _expiringSubscriptions == null || _expiringSubscriptions!.isEmpty
                  ? _buildEmptyState(context, textTheme, colorScheme)
                  : _buildSubscriptionsList(context, textTheme, colorScheme),
    );
  }

  Widget _buildEmptyState(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 24),
          Text(
            'All Good!',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'No memberships are expiring in the next 7 days.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsList(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _expiringSubscriptions!.length,
      itemBuilder: (context, index) {
        final sub = _expiringSubscriptions![index];
        final user = sub['User'];
        final endDate = DateTime.parse(sub['endDate']);
        final daysRemaining = endDate.difference(DateTime.now()).inDays + 1;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user?['username'] ?? 'Unknown Owner',
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$daysRemaining Days Left',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(user?['email'] ?? 'No email', style: textTheme.bodyMedium),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CURRENT PLAN', style: textTheme.labelSmall),
                        Text(sub['planName'] ?? 'Pro Pack', style: textTheme.titleMedium),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('EXPIRY DATE', style: textTheme.labelSmall),
                        Text(dateFormat.format(endDate), style: textTheme.titleMedium),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
