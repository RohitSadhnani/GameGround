import 'package:flutter/material.dart';
import 'package:frontend/features/subscription/data/subscription_service.dart';
import 'package:frontend/features/subscription/presentation/pages/subscription_payment_page.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;

  // Default hardcoded plans as fallback
  static const List<Map<String, dynamic>> _defaultPlans = [
    {
      'name': '1 Month Pack',
      'price': 999,
      'durationMonths': 1,
      'features': ['List Venues', 'Manage Bookings', 'Basic Analytics'],
      'isPopular': false,
      'badgeText': null,
    },
    {
      'name': '6 Month Pack',
      'price': 4999,
      'durationMonths': 6,
      'features': ['All 1 Month features', 'Priority Support', 'Advanced Analytics'],
      'isPopular': true,
      'badgeText': 'Save 16%',
    },
    {
      'name': '1 Year Pack',
      'price': 8999,
      'durationMonths': 12,
      'features': ['All 6 Month features', 'Featured Listing', 'Dedicated Manager'],
      'isPopular': false,
      'badgeText': 'Best Value',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final dynamicPlans = await SubscriptionService.getAvailablePlans();
      if (mounted) {
        setState(() {
          if (dynamicPlans.isNotEmpty) {
            // Combine default plans with dynamic ones
            _plans = [
              ..._defaultPlans,
              ...dynamicPlans.map((p) => Map<String, dynamic>.from(p)),
            ];
          } else {
            _plans = [..._defaultPlans];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _plans = [..._defaultPlans];
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
        title: const Text('Upgrade to Venue Owner'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'List Venues & Manage Bookings',
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock the power to manage your sports facility and start earning today.',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    ...List.generate(_plans.length, (index) {
                      final plan = _plans[index];
                      final features = (plan['features'] is List)
                          ? List<String>.from(plan['features'])
                          : <String>[];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildPricingCard(
                          context,
                          title: plan['name'] ?? 'Plan',
                          price: double.tryParse(plan['price'].toString()) ?? 0,
                          months: plan['durationMonths'] is int ? plan['durationMonths'] : int.tryParse(plan['durationMonths'].toString()) ?? 1,
                          features: features,
                          isPopular: plan['isPopular'] == true,
                          badgeText: plan['badgeText'],
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context, {
    required String title,
    required double price,
    required int months,
    required List<String> features,
    bool isPopular = false,
    String? badgeText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: isPopular ? colorScheme.primaryContainer.withOpacity(0.1) : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular ? colorScheme.primary : colorScheme.outlineVariant,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPopular ? colorScheme.primary : colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: textTheme.labelSmall?.copyWith(
                        color: isPopular ? colorScheme.onPrimary : colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${price.toInt()}',
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                  child: Text(
                    ' / $months ${months == 1 ? "month" : "months"}',
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(feature, style: textTheme.bodyMedium),
                ],
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: isPopular 
                ? ElevatedButton(
                    onPressed: () => _navigateToPayment(context, title, price, months),
                    child: const Text('Choose Plan'),
                  )
                : OutlinedButton(
                    onPressed: () => _navigateToPayment(context, title, price, months),
                    child: const Text('Choose Plan'),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPayment(BuildContext context, String planName, double price, int months) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionPaymentPage(
          planName: planName,
          price: price,
          durationMonths: months,
        ),
      ),
    );
  }
}
