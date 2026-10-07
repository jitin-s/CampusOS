import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/lost_found_entity.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/lost_found_controller.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        context.read<LostFoundController>().loadItems(campusId: user.campusId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryBlue,
            indicatorColor: AppTheme.primaryBlue,
            tabs: const [
              Tab(icon: Icon(Icons.search), text: 'Browse All'),
              Tab(icon: Icon(Icons.help_outline), text: 'Report Lost'),
              Tab(icon: Icon(Icons.volunteer_activism), text: 'Report Found'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _BrowseItemsView(),
          _ReportItemForm(
            itemType: ItemType.lost,
            onSuccess: () => _tabController.animateTo(0),
          ),
          _ReportItemForm(
            itemType: ItemType.found,
            onSuccess: () => _tabController.animateTo(0),
          ),
        ],
      ),
    );
  }
}

class _BrowseItemsView extends StatelessWidget {
  const _BrowseItemsView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LostFoundController>();

    if (controller.isLoading && controller.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.items.isEmpty) {
      return const Center(child: Text('No lost or found items reported.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.items.length,
      itemBuilder: (context, index) {
        final item = controller.items[index];
        final isFound = item.itemType == ItemType.found;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        isFound ? 'FOUND ITEM' : 'LOST ITEM',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      backgroundColor: isFound
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                    ),
                    Chip(
                      label: Text(
                        item.status.name.toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.itemName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Location: ${item.location}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                if (item.brand != null || item.color != null)
                  Text(
                    'Details: ${item.brand ?? ""} • ${item.color ?? ""}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                const SizedBox(height: 8),
                Text(item.description, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                if (isFound && item.status == ItemStatus.open) ...[
                  // Explainable Match & Claim Dialog Trigger (UX Spec Section 8)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.verified_user_outlined),
                        label: const Text('Verify & Claim Item'),
                        onPressed: () => _showClaimDialog(context, item),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClaimDialog(BuildContext context, LostFoundItemEntity item) {
    final answerController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ownership Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To protect lost property, explain distinguishing marks, contents, or serial identifier:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: answerController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g. Scratches on left corner, sticker on back...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (answerController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                await context.read<LostFoundController>().claimItem(item.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Claim submitted for administrator review!',
                      ),
                      backgroundColor: AppTheme.statusResolved,
                    ),
                  );
                }
              }
            },
            child: const Text('Submit Claim'),
          ),
        ],
      ),
    );
  }
}

class _ReportItemForm extends StatefulWidget {
  final ItemType itemType;
  final VoidCallback onSuccess;

  const _ReportItemForm({required this.itemType, required this.onSuccess});

  @override
  State<_ReportItemForm> createState() => _ReportItemFormState();
}

class _ReportItemFormState extends State<_ReportItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Electronics';

  final List<String> _categories = [
    'Electronics',
    'Stationery',
    'Identity / Cards',
    'Clothing',
    'Keys',
    'Accessories',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthController>().currentUser;
    if (user == null) return;

    final item = LostFoundItemEntity(
      id: '',
      campusId: user.campusId,
      userId: user.id,
      itemType: widget.itemType,
      category: _category,
      itemName: _nameController.text.trim(),
      brand: _brandController.text.trim().isNotEmpty
          ? _brandController.text.trim()
          : null,
      color: _colorController.text.trim().isNotEmpty
          ? _colorController.text.trim()
          : null,
      location: _locationController.text.trim(),
      occurredAt: DateTime.now(),
      description: _descriptionController.text.trim(),
      status: ItemStatus.open,
      createdAt: DateTime.now(),
    );

    final res = await context.read<LostFoundController>().submitItem(item);
    if (res != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.itemType == ItemType.lost ? "Lost item report" : "Found item"} submitted!',
          ),
          backgroundColor: AppTheme.statusResolved,
        ),
      );
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLost = widget.itemType == ItemType.lost;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isLost ? 'Report a Lost Item' : 'Report a Found Item',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _category = val ?? 'Electronics'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText:
                        'e.g. Casio Scientific Calculator, Blue Water Bottle',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                          labelText: 'Brand (Optional)',
                          hintText: 'e.g. Casio, Apple',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(
                          labelText: 'Color (Optional)',
                          hintText: 'e.g. Black, Silver',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Where did you lose or find this?',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Include unique traits, stickers, scratches...',
                  ),
                  validator: (v) => (v == null || v.length < 5)
                      ? 'Please describe the item'
                      : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    isLost ? 'Submit Lost Report' : 'Submit Found Report',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
