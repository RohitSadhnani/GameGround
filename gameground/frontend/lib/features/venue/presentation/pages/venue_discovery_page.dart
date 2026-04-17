import 'package:flutter/material.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/booking/presentation/pages/booking_page.dart';
import 'package:frontend/features/venue/data/venue_service.dart';
import 'package:frontend/features/auth/data/auth_service.dart';
import 'package:frontend/features/notification/presentation/pages/notifications_page.dart';
import 'package:frontend/features/coaching/presentation/pages/coaching_page.dart';

class VenueDiscoveryPage extends StatefulWidget {
  const VenueDiscoveryPage({super.key});

  @override
  State<VenueDiscoveryPage> createState() => _VenueDiscoveryPageState();
}

class _VenueDiscoveryPageState extends State<VenueDiscoveryPage> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Football',
    'Basketball',
    'Tennis',
    'Cricket',
    'Badminton',
  ];
  List<dynamic> _venues = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchVenues();
  }

  Future<void> _fetchVenues() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final isOwner = AuthService.role == 'venue_owner';
      final token = AuthService.token;

      List<dynamic> fetchedVenues = [];

      if (isOwner && token != null) {
        fetchedVenues = await VenueService.getMyVenues(token);
      } else {
        fetchedVenues = await VenueService.getAllVenues();
      }

      setState(() {
        _venues = fetchedVenues;
        _isLoading = false;
      });
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
        title: const Text('Venues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                'Sports Categories',
                style: textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(color: colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: colorScheme.surface,
                          icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface),
                          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            }
                          },
                          items: _categories.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CoachingPage()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Coaching'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Text(
                'All Venues',
                style: textTheme.headlineMedium,
              ),
            ),

            // Venue List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : _buildVenueList(colorScheme, textTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueList(ColorScheme colorScheme, TextTheme textTheme) {
    final isOwner = AuthService.role == 'venue_owner';

    var filteredVenues = _venues.where((v) {
      final sport = v['sportType'] ?? v['sport'] ?? '';
      return _selectedCategory == 'All' ||
          sport.toString().toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    if (filteredVenues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'No venues found',
              style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different category or check back later',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _fetchVenues,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredVenues.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final venue = filteredVenues[index];
        final sport = venue['sportType'] ?? venue['sport'] ?? 'Other';
        return GestureDetector(
          onTap: isOwner
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingPage(
                        venueId: venue['id'],
                        venueName: venue['name'],
                      ),
                    ),
                  );
                },
          child: Card(
            margin: const EdgeInsets.only(bottom: 24),
            clipBehavior: Clip.antiAlias,
            // Uses global card theme (16px radius, subtle border, 0 elevation)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200, // Slightly taller image
                      width: double.infinity,
                      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
                      child: _buildVenueImages(venue, sport, colorScheme),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sport,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0), // increased padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              venue['name'],
                              style: textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Text(
                                '₹${venue['pricePerHour'] ?? venue['price'] ?? 0}/hr',
                                style: textTheme.titleLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (AuthService.role == 'venue_owner')
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: colorScheme.error,
                                  ),
                                  onPressed: () {
                                    _showDeleteConfirmation(venue['id']);
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              venue['location'],
                              style: textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (venue['phoneNumber'] != null &&
                          venue['phoneNumber'].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              venue['phoneNumber'],
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                      if (!isOwner) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingPage(
                                    venueId: venue['id'],
                                    venueName: venue['name'],
                                  ),
                                ),
                              );
                            },
                            child: const Text('Book Now'),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'Football':
        return Icons.sports_soccer;
      case 'Basketball':
        return Icons.sports_basketball;
      case 'Tennis':
        return Icons.sports_tennis;
      case 'Cricket':
        return Icons.sports_cricket;
      case 'Badminton':
        return Icons.sports_handball; // Fallback for badminton
      default:
        return Icons.sports;
    }
  }

  void _showDeleteConfirmation(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Venue'),
        content: const Text(
          'Are you sure you want to remove this venue from listings?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await VenueService.deleteVenue(id);
                if (mounted) {
                  setState(() {
                    _venues.removeWhere((v) => v['id'] == id);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Venue deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete venue: $e')),
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
  Widget _buildVenueImages(dynamic venue, String sport, ColorScheme colorScheme) {
    List<String> validImageUrls = [];
    if (venue['imageUrls'] != null && venue['imageUrls'] is List) {
       validImageUrls = List<String>.from(venue['imageUrls']);
    } else if (venue['imageUrl'] != null && venue['imageUrl'].toString().isNotEmpty) {
       validImageUrls = [venue['imageUrl'].toString()];
    }

    if (validImageUrls.isEmpty) {
        return Center(
          child: Icon(
            _getSportIcon(sport),
            size: 80,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        );
    }

    if (validImageUrls.length == 1) {
        return _buildSingleImage(validImageUrls.first, sport, colorScheme);
    }

    return Stack(
      children: [
        PageView.builder(
            itemCount: validImageUrls.length,
            itemBuilder: (context, index) {
                return _buildSingleImage(validImageUrls[index], sport, colorScheme);
            },
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_library, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${validImageUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSingleImage(String url, String sport, ColorScheme colorScheme) {
      return Image.network(
          url.startsWith('http') ? url : '${ApiConstants.imageBaseUrl}$url',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              _getSportIcon(sport),
              size: 80,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
      );
  }
}
