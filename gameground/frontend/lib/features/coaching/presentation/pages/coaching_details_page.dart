import 'package:flutter/material.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/auth_service.dart';
import 'package:frontend/features/coaching/presentation/pages/coaching_payment_page.dart';

class CoachingDetailsPage extends StatelessWidget {
  final dynamic coaching;

  const CoachingDetailsPage({super.key, required this.coaching});

  @override
  Widget build(BuildContext context) {
    final bool isOwner = AuthService.role == 'venue_owner';
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(coaching['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (coaching['pic'] != null)
              Image.network(
                coaching['pic'].toString().startsWith('http')
                    ? coaching['pic']
                    : '${ApiConstants.imageBaseUrl}${coaching['pic']}',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 250,
                  color: colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(Icons.image_not_supported, size: 50, color: colorScheme.onSurfaceVariant)
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coaching['name'],
                    style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.phone, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(coaching['mobileNo'], style: textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text('Duration: ${coaching['durationMonths']} months', style: textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.currency_rupee, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        '₹${coaching['pricePerMonth']} / month',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  if (!isOwner)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CoachingPaymentPage(coaching: coaching),
                            ),
                          );
                        },
                        child: Text(
                          'REGISTER & PAY',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          )
                        ),
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
