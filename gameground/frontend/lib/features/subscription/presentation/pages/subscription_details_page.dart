import 'package:flutter/material.dart';
import 'package:frontend/features/subscription/data/subscription_service.dart';
import 'package:frontend/features/subscription/presentation/pages/subscription_page.dart';
import 'package:intl/intl.dart';

class SubscriptionDetailsPage extends StatefulWidget {
  const SubscriptionDetailsPage({super.key});

  @override
  State<SubscriptionDetailsPage> createState() => _SubscriptionDetailsPageState();
}

class _SubscriptionDetailsPageState extends State<SubscriptionDetailsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _subscription;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSubscription();
  }

  Future<void> _fetchSubscription() async {
    try {
      final sub = await SubscriptionService.getMySubscription();
      if (mounted) {
        setState(() {
          _subscription = sub;
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
        title: const Text('Membership Details'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _subscription == null
                  ? _buildNoSubscription(context, textTheme, colorScheme)
                  : _buildSubscriptionDetails(context, textTheme, colorScheme),
    );
  }

  Widget _buildNoSubscription(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_membership, size: 80, color: colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 24),
          Text(
            'No Active Membership',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'You don\'t have an active subscription at the moment.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                ).then((_) => _fetchSubscription());
              },
              child: const Text('VIEW PLANS'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    final sub = _subscription!;
    final startDate = DateTime.parse(sub['startDate']);
    final endDate = DateTime.parse(sub['endDate']);
    final dateFormat = DateFormat('dd MMM yyyy');
    
    final bool isExpired = endDate.isBefore(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CURRENT PLAN',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isExpired ? colorScheme.error : colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isExpired ? 'EXPIRED' : 'ACTIVE',
                        style: textTheme.labelSmall?.copyWith(
                          color: isExpired ? colorScheme.onError : colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  sub['planName'] ?? 'Pro Membership',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDateInfo('START DATE', dateFormat.format(startDate), colorScheme),
                    _buildDateInfo('EXPIRY DATE', dateFormat.format(endDate), colorScheme),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Membership Benefits',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(Icons.check_circle, 'List unlimited sports venues', colorScheme, textTheme),
          _buildBenefitItem(Icons.check_circle, 'Access to detailed revenue reports', colorScheme, textTheme),
          _buildBenefitItem(Icons.check_circle, 'Direct notifications for new bookings', colorScheme, textTheme),
          _buildBenefitItem(Icons.check_circle, 'Priority support for owners', colorScheme, textTheme),
          
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                ).then((_) => _fetchSubscription());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(isExpired ? 'RENEW MEMBERSHIP' : 'UPGRADE / EXTEND PLAN'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String date, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onPrimary.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String text, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
