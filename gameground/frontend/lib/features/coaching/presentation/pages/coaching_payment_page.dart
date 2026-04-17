import 'package:flutter/material.dart';
import 'package:frontend/features/coaching/data/coaching_service.dart';

class CoachingPaymentPage extends StatefulWidget {
  final dynamic coaching;

  const CoachingPaymentPage({super.key, required this.coaching});

  @override
  State<CoachingPaymentPage> createState() => _CoachingPaymentPageState();
}

class _CoachingPaymentPageState extends State<CoachingPaymentPage> {
  bool _isProcessing = false;
  String _paymentMethod = 'Cash';

  Future<void> _processPayment(ColorScheme colorScheme) async {
    if (_paymentMethod == 'UPI') {
      _showUpiDialog(colorScheme);
      return;
    }
    await _executePayment('Cash', colorScheme);
  }

  Future<void> _executePayment(String method, ColorScheme colorScheme) async {
    setState(() => _isProcessing = true);
    try {
      // Simulate network delay for payment processing
      await Future.delayed(const Duration(seconds: 1));

      // total amount = price per month * duration in months
      final double totalAmount = 
          double.parse(widget.coaching['pricePerMonth'].toString()) * 
          int.parse(widget.coaching['durationMonths'].toString());

      await CoachingService.registerForCoaching({
        'coachingId': widget.coaching['id'],
        'amount': totalAmount,
        'paymentMethod': method,
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Successfully registered for the coaching session!'),
            actions: [
              TextButton(
                onPressed: () {
                  // Pop dialog, pop payment page, pop details page to go back to coaching list
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showUpiDialog(ColorScheme colorScheme) {
    final upiIdController = TextEditingController();
    final pinController = TextEditingController();
    bool dialogIsLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Enter UPI Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: upiIdController,
                  decoration: const InputDecoration(labelText: 'UPI ID'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'UPI PIN'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: dialogIsLoading ? null : () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: dialogIsLoading ? null : () async {
                  if (upiIdController.text.trim().isEmpty || pinController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter both UPI ID and PIN")));
                    return;
                  }
                  
                  setDialogState(() => dialogIsLoading = true);
                  
                  try {
                    await Future.delayed(const Duration(seconds: 1)); // Simulate network check
                    
                    final double totalAmount = 
                        double.parse(widget.coaching['pricePerMonth'].toString()) * 
                        int.parse(widget.coaching['durationMonths'].toString());

                    await CoachingService.registerForCoaching({
                      'coachingId': widget.coaching['id'],
                      'amount': totalAmount,
                      'paymentMethod': 'UPI',
                    });

                    if (!context.mounted) return;
                    Navigator.pop(context); // close dialog
                    
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                            title: const Text('Success'),
                            content: const Text('Successfully registered for the coaching session via UPI!'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                              ),
                            ],
                        ),
                    );
                  } catch (e) {
                    if (!context.mounted) {
                      setDialogState(() => dialogIsLoading = false);
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Payment failed: ${e.toString()}'),
                      backgroundColor: colorScheme.error,
                    ));
                    setDialogState(() => dialogIsLoading = false);
                  }
                },
                child: dialogIsLoading 
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2))
                    : const Text('PAY NOW'),
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

    final double totalAmount = 
          double.parse(widget.coaching['pricePerMonth'].toString()) * 
          int.parse(widget.coaching['durationMonths'].toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildSummaryRow('Session', widget.coaching['name'], textTheme, colorScheme),
            const SizedBox(height: 12),
            _buildSummaryRow('Duration', '${widget.coaching['durationMonths']} Months', textTheme, colorScheme),
            const SizedBox(height: 12),
            _buildSummaryRow('Price / Month', '₹${widget.coaching['pricePerMonth']}', textTheme, colorScheme),
            const Divider(height: 32),
            _buildSummaryRow('Total Amount', '₹$totalAmount', textTheme, colorScheme, isTotal: true),
            const SizedBox(height: 32),
            Text(
              'Payment Method',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text('Pay Cash on Arrival / Reception', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    value: 'Cash',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  ),
                  Divider(height: 1, color: colorScheme.outlineVariant),
                  RadioListTile<String>(
                    title: Text('UPI Payment', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    value: 'UPI',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _processPayment(colorScheme),
                child: _isProcessing
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2),
                      )
                    : Text(
                        'CONFIRM & PAY',
                        style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, TextTheme textTheme, ColorScheme colorScheme, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal ? textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold) 
                         : textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: isTotal ? textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary) 
                         : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
