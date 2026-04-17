import 'package:flutter/material.dart';
import 'package:frontend/features/coaching/data/coaching_service.dart';
import 'package:frontend/features/auth/data/auth_service.dart';

class MyCoachingsPage extends StatefulWidget {
  const MyCoachingsPage({super.key});

  @override
  State<MyCoachingsPage> createState() => _MyCoachingsPageState();
}

class _MyCoachingsPageState extends State<MyCoachingsPage> {
  late Future<List<dynamic>> _coachingsFuture;

  @override
  void initState() {
    super.initState();
    _coachingsFuture = _fetchMyCoachings();
  }

  Future<List<dynamic>> _fetchMyCoachings() async {
    try {
      final userId = AuthService.userId ?? 0;
      if (userId == 0) return [];
      // This gets payments with included Coaching info for the current Player
      return await CoachingService.getMyCoachings();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coaching Sessions'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _coachingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: colorScheme.error)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No coaching registrations found.', style: textTheme.bodyLarge));
          }

          final payments = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              final coaching = payment['Coaching'];
              
              if (coaching == null) return const SizedBox.shrink();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    coaching['name'] ?? 'Coaching Session',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Duration: ${coaching['durationMonths']} months',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount Paid: ₹${payment['amount']}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Payment Status: ${payment['paymentStatus'].toString().toUpperCase()}',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
