import 'package:flutter/material.dart';
import 'package:frontend/features/booking/data/payment_service.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const PaymentPage({super.key, required this.bookingData});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
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
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Go Home'),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _processPayOnSpot() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await PaymentService.payOnSpot(
        bookingId: widget.bookingData['bookingId'],
      );
      _showSuccessDialog("Booking Confirmed!\n\nPlease pay at the venue.");
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
                    await PaymentService.payWithUpi(
                      bookingId: widget.bookingData['bookingId'],
                      upiId: upiIdController.text.trim(),
                      pin: pinController.text.trim(),
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context); // close dialog
                    _showSuccessDialog("Booking Confirmed via UPI!");
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

    final amount = widget.bookingData['totalAmount'] ?? 0.0;
    final venueName = widget.bookingData['venueName'] ?? 'Venue';
    final timeSlot = widget.bookingData['timeSlot'] ?? '';

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
                  color: colorScheme.primary.withOpacity(0.1),
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
                                'Booking Summary',
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                venueName,
                                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.bookingData['bookingDate'] ?? 'Today',
                                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      timeSlot,
                                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                    ),
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
                              '₹$amount',
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
              
              // Pay on Spot (Cash)
              SizedBox(
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: _isProcessing ? null : _processPayOnSpot,
                  icon: const Icon(Icons.money),
                  label: const Text('Pay at Venue (Cash)'),
                ),
              ),
              const SizedBox(height: 16),
              // Pay with UPI
              SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _showUpiDialog,
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Pay via UPI'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
