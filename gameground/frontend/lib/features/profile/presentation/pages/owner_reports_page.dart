import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/auth_service.dart';

class OwnerReportsPage extends StatefulWidget {
  const OwnerReportsPage({super.key});

  @override
  State<OwnerReportsPage> createState() => _OwnerReportsPageState();
}

class _OwnerReportsPageState extends State<OwnerReportsPage> {
  List<dynamic> _reports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = AuthService.token;
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('${ApiConstants.bookings}/owner/reports'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _reports = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Booking Reports'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: colorScheme.error)))
              : _reports.isEmpty
                  ? Center(child: Text('No bookings found for your venues yet.', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _reports.length,
                      itemBuilder: (context, index) {
                        final report = _reports[index];
                        final String date = report['date'];
                        final List venues = report['venues'];

                        int totalSlotsForDate = 0;
                        double totalRevenueForDate = 0.0;
                        for (var v in venues) {
                          totalSlotsForDate += (v['totalSlotsBooked'] as int);
                          totalRevenueForDate += (v['revenue'] as num).toDouble();
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      date,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary, 
                                        borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Text(
                                        '$totalSlotsForDate Slots',
                                        style: textTheme.labelMedium?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 32),
                                ...venues.map((v) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              v['venueName'],
                                              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            '${v['totalSlotsBooked']} slots (₹${v['revenue']})',
                                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                    )),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Total Revenue: ₹$totalRevenueForDate',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green, // Keep green for positive money
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
