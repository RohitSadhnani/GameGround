import 'package:flutter/material.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/venue/presentation/pages/add_venue_page.dart';
import 'package:frontend/features/venue/presentation/pages/edit_venue_page.dart';
import 'package:frontend/features/coaching/presentation/pages/coaching_page.dart';
import 'package:frontend/features/venue/data/venue_service.dart';
import 'package:frontend/features/notification/presentation/pages/notifications_page.dart';
import 'package:frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend/features/auth/data/auth_service.dart';

class VenueOwnerDashboardPage extends StatefulWidget {
  const VenueOwnerDashboardPage({super.key});

  @override
  State<VenueOwnerDashboardPage> createState() => _VenueOwnerDashboardPageState();
}

class _VenueOwnerDashboardPageState extends State<VenueOwnerDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    OwnerDashboardTab(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class OwnerDashboardTab extends StatefulWidget {
  const OwnerDashboardTab({super.key});

  @override
  State<OwnerDashboardTab> createState() => _OwnerDashboardTabState();
}

class _OwnerDashboardTabState extends State<OwnerDashboardTab> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Football',
    'Basketball',
    'Tennis',
    'Cricket',
    'Badminton',
  ];
  List<dynamic> _myVenues = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = AuthService.token;
      if (token == null) throw Exception('Not authenticated');

      final venues = await VenueService.getMyVenues(token);
      
      if (mounted) {
        setState(() {
          _myVenues = venues;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error', style: TextStyle(color: colorScheme.error)));
    
    var filteredVenues = _myVenues.where((v) {
      final sport = v['sportType'] ?? v['sport'] ?? '';
      return _selectedCategory == 'All' ||
          sport.toString().toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              // Categories and Coaching Button mirroring Player Discover Page
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
                  'My Venues',
                  style: textTheme.headlineMedium,
                ),
              ),
            ]),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (filteredVenues.isEmpty)
                  _buildEmptyState('No venues listed yet', 'Start by adding your first sports venue', Icons.business, textTheme, colorScheme)
                else
                  ...filteredVenues.map((v) => _buildVenueCard(v, textTheme, colorScheme)),
                
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "add_venue",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddVenuePage()),
              );
              _fetchDashboardData();
            },
            label: const Text('Add Venue'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, TextTheme textTheme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildVenueCard(dynamic venue, TextTheme textTheme, ColorScheme colorScheme) {
    final sport = venue['sportType'] ?? venue['sport'] ?? 'Other';
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
                child: _buildDashboardThumbnail(venue, colorScheme),
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
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(20.0),
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
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: colorScheme.error,
                              ),
                              onPressed: () {
                                _showDeleteConfirmation(venue['id'], textTheme, colorScheme);
                              },
                              tooltip: 'Delete venue',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: colorScheme.primary,
                              ),
                              onPressed: () async {
                                final updated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditVenuePage(
                                      venue: Map<String, dynamic>.from(venue),
                                    ),
                                  ),
                                );
                                if (updated == true) {
                                  _fetchDashboardData();
                                }
                              },
                              tooltip: 'Edit venue',
                            ),
                          ],
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
                        venue['location'] ?? '',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(dynamic id, TextTheme textTheme, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Venue', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to remove this venue from listings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error, foregroundColor: colorScheme.onError),
            onPressed: () async {
              try {
                await VenueService.deleteVenue(id);
                if (mounted) {
                  setState(() {
                    _myVenues.removeWhere((v) => v['id'] == id);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Venue deleted successfully')),
                  );
                }
              } catch(e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardThumbnail(dynamic venue, ColorScheme colorScheme) {
    String? thumbUrl;
    if (venue['imageUrls'] != null && venue['imageUrls'] is List && venue['imageUrls'].isNotEmpty) {
      thumbUrl = venue['imageUrls'].first;
    } else if (venue['imageUrl'] != null && venue['imageUrl'].toString().isNotEmpty) {
      thumbUrl = venue['imageUrl'].toString();
    }

    if (thumbUrl != null) {
      return Image.network(
        thumbUrl.startsWith('http')
            ? thumbUrl
            : '${ApiConstants.imageBaseUrl}$thumbUrl',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.sports, color: colorScheme.onSurfaceVariant),
      );
    }
    return Icon(Icons.sports, color: colorScheme.onSurfaceVariant);
  }
}
