import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/lost_found_entity.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminLostFoundScreen extends StatelessWidget {
  const AdminLostFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminDashboardController>();
    final pendingClaims = controller.lostFoundItems
        .where(
          (i) =>
              i.status == ItemStatus.claimed || i.status == ItemStatus.matched,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found Claim Approvals & Vault'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.secondaryNavy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pendingClaims.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[400]!),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.pending_actions,
                      color: AppTheme.statusHigh,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${pendingClaims.length} ownership claims awaiting physical verification and desk handover.',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              'All Custody Items & Claims',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.lostFoundItems.length,
              itemBuilder: (context, index) {
                final item = controller.lostFoundItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.itemType == ItemType.found
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      child: Icon(
                        item.itemType == ItemType.found
                            ? Icons.volunteer_activism
                            : Icons.help_outline,
                        color: item.itemType == ItemType.found
                            ? Colors.green[800]
                            : Colors.red[800],
                        size: 20,
                      ),
                    ),
                    title: Text(
                      '${item.itemName} (${item.category})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Location: ${item.location} • Status: ${item.status.name.toUpperCase()}',
                    ),
                    trailing: item.status == ItemStatus.claimed
                        ? ElevatedButton(
                            onPressed: () =>
                                _showClaimVerificationDialog(context, item),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.statusResolved,
                            ),
                            child: const Text('Verify Claim'),
                          )
                        : Chip(
                            label: Text(
                              item.status.name.toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClaimVerificationDialog(
    BuildContext context,
    LostFoundItemEntity item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Ownership Claim & Handover'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item: ${item.itemName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Location Found: ${item.location}'),
            const SizedBox(height: 12),
            const Text(
              'AI Match Confidence: 94% (Category, Brand & Location confirmed)',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[100],
              child: const Text(
                'Claimant Proof Note:\n"Casio scientific calculator with faded school barcode sticker on back lid."',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Reject Claim'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdminDashboardController>().approveClaim(
                item.id,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Claim verified! Item marked Recovered and closed.',
                    ),
                    backgroundColor: AppTheme.statusResolved,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusResolved,
            ),
            child: const Text('Approve & Handover'),
          ),
        ],
      ),
    );
  }
}
