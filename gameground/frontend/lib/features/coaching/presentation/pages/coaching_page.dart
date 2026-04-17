import 'package:flutter/material.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/auth_service.dart';
import 'package:frontend/features/coaching/data/coaching_service.dart';
import 'package:frontend/features/coaching/presentation/pages/add_coaching_page.dart';
import 'package:frontend/features/coaching/presentation/pages/coaching_details_page.dart';

class CoachingPage extends StatefulWidget {
  const CoachingPage({super.key});

  @override
  State<CoachingPage> createState() => _CoachingPageState();
}

class _CoachingPageState extends State<CoachingPage> {
  final bool isOwner = AuthService.role == 'venue_owner';
  bool _isLoading = true;
  List<dynamic> _coachings = [];

  @override
  void initState() {
    super.initState();
    _fetchCoachings();
  }

  Future<void> _fetchCoachings() async {
    setState(() => _isLoading = true);
    try {
      final data = isOwner
          ? await CoachingService.getMyCoachings()
          : await CoachingService.getAllCoachings();
      if (mounted) {
        setState(() {
          _coachings = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coaching Sessions'),
        actions: [
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchCoachings,
            ),
        ]
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _coachings.isEmpty
              ? Center(
                  child: Text('No coaching sessions found.', 
                    style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant))
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _coachings.length,
                  itemBuilder: (context, index) {
                    final coaching = _coachings[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CoachingDetailsPage(coaching: coaching),
                            ),
                          ).then((_) => _fetchCoachings());
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (coaching['pic'] != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(
                                  coaching['pic'].toString().startsWith('http')
                                      ? coaching['pic']
                                      : '${ApiConstants.imageBaseUrl}${coaching['pic']}',
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 150,
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Center(child: Icon(Icons.image_not_supported, color: colorScheme.onSurfaceVariant)),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    coaching['name'],
                                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Duration: ${coaching['durationMonths']} months',
                                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${coaching['pricePerMonth']} / month',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCoachingPage()),
                ).then((_) => _fetchCoachings());
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
