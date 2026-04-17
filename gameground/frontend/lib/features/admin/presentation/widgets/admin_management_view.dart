import 'package:flutter/material.dart';
import 'package:frontend/features/admin/data/admin_service.dart';

class AdminManagementView extends StatefulWidget {
  final Map<String, dynamic>? stats;

  const AdminManagementView({
    super.key,
    required this.stats,
  });

  @override
  State<AdminManagementView> createState() => _AdminManagementViewState();
}

class _AdminManagementViewState extends State<AdminManagementView> {
  List<dynamic> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('DEBUG: AdminManagementView (NEW VERSION) Initialized');
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    final plans = await AdminService.getPlans();
    if (mounted) {
      setState(() {
        _plans = plans ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Plans',
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Create and manage plans visible to venue owners',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: _loadPlans,
                    icon: const Icon(Icons.refresh, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => _showPlanDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Plan'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_plans.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(Icons.card_membership, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text('No plans created yet', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('Tap "Add Plan" to create your first subscription plan.', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_plans.length, (index) {
              final plan = _plans[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPlanCard(context, plan),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPopular = plan['isPopular'] == true;
    final isActive = plan['isActive'] == true;
    final features = (plan['features'] is List) ? List<String>.from(plan['features']) : <String>[];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPopular ? colorScheme.primary : colorScheme.outlineVariant,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        plan['name'] ?? 'Unnamed',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (plan['badgeText'] != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isPopular ? colorScheme.primary : colorScheme.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            plan['badgeText'],
                            style: textTheme.labelSmall?.copyWith(
                              color: isPopular ? colorScheme.onPrimary : colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (!isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Inactive', style: textTheme.labelSmall?.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showPlanDialog(context, plan: plan);
                    } else if (value == 'delete') {
                      _confirmDelete(context, plan);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Deactivate')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${double.tryParse(plan['price'].toString())?.toInt() ?? plan['price']}',
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(
                    ' / ${plan['durationMonths']} ${plan['durationMonths'] == 1 ? "month" : "months"}',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            if (features.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: features.map((f) => Chip(
                  avatar: Icon(Icons.check_circle, color: colorScheme.primary, size: 16),
                  label: Text(f, style: textTheme.bodySmall),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPlanDialog(BuildContext context, {Map<String, dynamic>? plan}) {
    final isEditing = plan != null;
    final nameCtrl = TextEditingController(text: plan?['name'] ?? '');
    final priceCtrl = TextEditingController(text: plan != null ? double.tryParse(plan['price'].toString())?.toInt().toString() ?? '' : '');
    final monthsCtrl = TextEditingController(text: plan?['durationMonths']?.toString() ?? '');
    final badgeCtrl = TextEditingController(text: plan?['badgeText'] ?? '');
    final featuresCtrl = TextEditingController(
      text: plan != null && plan['features'] is List
          ? (plan['features'] as List).join(', ')
          : '',
    );
    bool isPopular = plan?['isPopular'] == true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Plan' : 'Create New Plan'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Plan Name *', hintText: 'e.g., 3 Month Pack'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Price (₹) *', hintText: 'e.g., 2499'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: monthsCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Duration (months) *', hintText: 'e.g., 3'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: featuresCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Features (comma-separated)',
                          hintText: 'e.g., List Venues, Priority Support',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: badgeCtrl,
                        decoration: const InputDecoration(labelText: 'Badge Text (optional)', hintText: 'e.g., Best Value'),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Mark as Popular'),
                        subtitle: const Text('Highlights this plan with the primary color'),
                        value: isPopular,
                        onChanged: (val) => setDialogState(() => isPopular = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final priceStr = priceCtrl.text.trim().replaceAll(RegExp(r'[^0-9.]'), '');
                    final monthsStr = monthsCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
                    
                    final price = double.tryParse(priceStr) ?? 0.0;
                    final months = int.tryParse(monthsStr) ?? 1;

                    print('Creating plan: name=$name, price=$price, months=$months');

                    final features = featuresCtrl.text.trim().isNotEmpty
                        ? featuresCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                        : <String>[];

                    final data = {
                      'name': name,
                      'price': price,
                      'durationMonths': months,
                      'features': features,
                      'badgeText': badgeCtrl.text.trim().isNotEmpty ? badgeCtrl.text.trim() : null,
                      'isPopular': isPopular,
                    };

                    final localPlan = plan;
                    bool success;
                    if (isEditing && localPlan != null) {
                      success = await AdminService.updatePlan(localPlan['id'], data);
                    } else {
                      success = await AdminService.createPlan(data);
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isEditing ? 'Plan updated!' : 'Plan created!'), backgroundColor: Colors.green),
                        );
                        _loadPlans();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Operation failed. Please try again.'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Create Plan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Plan?'),
        content: Text('This will hide "${plan['name']}" from venue owners. You can re-activate it later.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await AdminService.deletePlan(plan['id']);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan deactivated'), backgroundColor: Colors.green),
                  );
                  _loadPlans();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to deactivate plan'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}
