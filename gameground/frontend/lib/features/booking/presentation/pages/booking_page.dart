import 'package:flutter/material.dart';
import 'package:frontend/features/booking/presentation/pages/payment_page.dart';
import 'package:frontend/features/booking/data/booking_service.dart';
import 'package:frontend/features/venue/data/venue_service.dart';
import 'package:frontend/features/auth/data/auth_service.dart';
import 'dart:convert';

class BookingPage extends StatefulWidget {
  final int venueId;
  final String venueName;
  const BookingPage({super.key, required this.venueId, required this.venueName});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final Set<int> _selectedSlotIndices = {};
  bool _isBooking = false;
  
  List<String> _timeSlots = [];
  bool _isLoading = true;
  double _price = 0.0;
  String? _error;
  List<String> _bookedSlots = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchVenueDetails();
  }

  Future<void> _fetchVenueDetails() async {
    try {
      // In a real app you'd call a dedicated endpoint like /api/venues/:id
      // but for simplicity we will reuse get all and find ours
      final venues = await VenueService.getAllVenues(); // Ideally from a dedicated fetch by ID
      final venue = venues.firstWhere((v) => v['id'] == widget.venueId, orElse: () => null);

      if (venue != null) {
        setState(() {
          if (venue['availableSlots'] is String) {
            _timeSlots = List<String>.from(jsonDecode(venue['availableSlots']));
          } else if (venue['availableSlots'] != null) {
            _timeSlots = List<String>.from(venue['availableSlots']);
          } else {
            _timeSlots = ['08:00 AM', '10:00 AM']; // Fallback
          }
          
          _price = double.parse((venue['pricePerHour'] ?? venue['price'] ?? 0).toString());
        });

        // Fetch booked slots
        await _fetchBookedSlotsForDate(_selectedDate);
      } else {
        setState(() {
          _error = 'Venue not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBookedSlotsForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final booked = await BookingService.getBookedSlotsForVenue(widget.venueId, dateStr);
      
      setState(() {
        _bookedSlots = booked;
        
        // Clear selected slots when changing dates to prevent accidental cross-date bookings
        _selectedSlotIndices.clear(); 
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Prevent booking in the past
      lastDate: DateTime.now().add(const Duration(days: 30)), // Allow booking up to 30 days in advance
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _fetchBookedSlotsForDate(_selectedDate);
    }
  }

  Future<void> _handleConfirmBooking() async {
    if (_selectedSlotIndices.isEmpty) return;

    setState(() {
      _isBooking = true;
    });

    try {
      final userId = AuthService.userId ?? 0;
      
      // Convert selected indices to a comma-separated string of time slots
      final selectedSlots = _selectedSlotIndices.map((i) => _timeSlots[i]).toList();
      final slotsString = selectedSlots.join(',');
      final totalPrice = _price * selectedSlots.length; // Multiply base price by number of slots

      final bookingResponse = await BookingService.createBooking(
        venueId: widget.venueId,
        userId: userId,
        bookingDate: _selectedDate.toIso8601String().split('T')[0],
        timeSlot: slotsString,
        totalAmount: totalPrice,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              bookingData: {
                'bookingId': bookingResponse['id'],
                'venueName': widget.venueName,
                'timeSlot': slotsString,
                'bookingDate': _selectedDate.toIso8601String().split('T')[0],
                'totalAmount': totalPrice,
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
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
        title: Text(widget.venueName.toUpperCase()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error', style: TextStyle(color: colorScheme.error)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: OutlinedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: Icon(Icons.calendar_today, color: colorScheme.onSurface, size: 20),
                        label: Text(
                          'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _timeSlots.isEmpty  
                        ? Center(child: Text('NO SLOTS AVAILABLE', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)))
                        : GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2.0,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _timeSlots.length,
                            itemBuilder: (context, index) {
                              final slotName = _timeSlots[index];
                              
                              // Check if any part of the slot is booked by splitting on comma just in case
                              bool isBooked = false;
                              for (var bookedStr in _bookedSlots) {
                                if (bookedStr.split(',').contains(slotName)) {
                                  isBooked = true;
                                  break;
                                }
                              }

                              final isSelected = _selectedSlotIndices.contains(index);
                              
                              Color containerBorderColor;
                              Color containerBackgroundColor;
                              Color textColor;

                              if (isBooked) {
                                containerBorderColor = colorScheme.outlineVariant;
                                containerBackgroundColor = colorScheme.surfaceContainerHighest;
                                textColor = colorScheme.onSurfaceVariant.withOpacity(0.5);
                              } else if (isSelected) {
                                containerBorderColor = colorScheme.primary;
                                containerBackgroundColor = colorScheme.primary;
                                textColor = colorScheme.onPrimary;
                              } else {
                                containerBorderColor = colorScheme.outlineVariant;
                                containerBackgroundColor = colorScheme.surface;
                                textColor = colorScheme.onSurface;
                              }

                              return InkWell(
                                onTap: isBooked ? null : () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedSlotIndices.remove(index);
                                    } else {
                                      _selectedSlotIndices.add(index);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: containerBackgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: containerBorderColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    slotName,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      decoration: isBooked ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    ),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(
                       '${_selectedSlotIndices.length} SLOTS SELECTED',
                       style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                     ),
                     Text(
                       'TOTAL: ₹${(_price * _selectedSlotIndices.length).toStringAsFixed(0)}',
                       style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                     )
                   ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_selectedSlotIndices.isNotEmpty && !_isBooking)
                        ? _handleConfirmBooking
                        : null,
                    child: _isBooking 
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                          )
                        : const Text('CONFIRM BOOKING'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
