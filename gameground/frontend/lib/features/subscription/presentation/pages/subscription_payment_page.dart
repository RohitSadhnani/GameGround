import 'package:flutter/material.dart';
import 'package:frontend/features/subscription/data/subscription_service.dart';
import 'package:frontend/features/auth/data/auth_service.dart';
import 'package:frontend/features/venue/presentation/pages/venue_owner_dashboard_page.dart';

class SubscriptionPaymentPage extends StatefulWidget {
  final String planName;
  final double price;
  final int durationMonths;

  const SubscriptionPaymentPage({
    super.key,
    required this.planName,
    required this.price,
    required this.durationMonths,
  });

  @override
  State<SubscriptionPaymentPage> createState() => _SubscriptionPaymentPageState();
}

class _SubscriptionPaymentPageState extends State<SubscriptionPaymentPage> {
  bool _isProcessing = false;

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showSuccessDialog(String message) {
    if (mounted) {
      final textTheme = Theme.of(context).textTheme;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const VenueOwnerDashboardPage()),
                    (route) => false,
                  );
                },
                child: const Text('Go to Dashboard'),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _processPayment(String method) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await SubscriptionService.purchaseSubscription(
        planName: widget.planName.toString(),
        amount: widget.price.toDouble(),
        paymentMethod: method.toString(),
        durationMonths: widget.durationMonths.toInt(),
      );
      
      // Update local role
      await AuthService.updateRole('venue_owner');

      _showSuccessDialog("Payment Successful!\n\nWelcome to your Venue Owner Dashboard.");
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showUpiDialog() {
    final upiIdController = TextEditingController();
    final pinController = TextEditingController();
    bool dialogIsLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final colorScheme = Theme.of(context).colorScheme;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Enter UPI Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: upiIdController,
                  decoration: const InputDecoration(
                    labelText: 'UPI ID',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'UPI PIN',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: dialogIsLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: dialogIsLoading ? null : () async {
                  if (upiIdController.text.trim().isEmpty || pinController.text.trim().isEmpty) {
                    _showErrorSnackBar("Please enter both UPI ID and PIN");
                    return;
                  }
                  
                  setDialogState(() => dialogIsLoading = true);
                  
                  try {
                    await SubscriptionService.purchaseSubscription(
                      planName: widget.planName,
                      amount: widget.price,
                      paymentMethod: 'UPI',
                      durationMonths: widget.durationMonths,
                    );
                    
                    // Update local role
                    await AuthService.updateRole('venue_owner');

                    if (!mounted) return;
                    Navigator.pop(context); // close dialog
                    _showSuccessDialog("Payment Successful via UPI!\n\nWelcome to your Venue Owner Dashboard.");
                  } catch (e) {
                    _showErrorSnackBar(e.toString());
                    setDialogState(() => dialogIsLoading = false);
                  }
                },
                child: dialogIsLoading 
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2))
                    : const Text('Pay Now'),
              ),
            ],
          );
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subscription Upgrade',
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.planName,
                                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Duration: ${widget.durationMonths} ${widget.durationMonths == 1 ? "Month" : "Months"}',
                                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total',
                              style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${widget.price.toInt()}',
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Payment Method',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Pay via UPI
              SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _showUpiDialog,
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Pay via UPI'),
                ),
              ),
              const SizedBox(height: 16),
              // Dummy Credit Card / Net Banking equivalent
              SizedBox(
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: _isProcessing ? null : () => _processPayment('Card'),
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Pay via Card / Bank'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
