import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminQueuesScreen extends StatefulWidget {
  const AdminQueuesScreen({super.key});

  @override
  State<AdminQueuesScreen> createState() => _AdminQueuesScreenState();
}

class _AdminQueuesScreenState extends State<AdminQueuesScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminDashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Queue Controller & Dispenser'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.secondaryNavy,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.queues.length,
        itemBuilder: (context, index) {
          final queue = controller.queues[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        queue.serviceName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(queue.isActive ? 'ACTIVE' : 'PAUSED'),
                        backgroundColor: queue.isActive
                            ? const Color(0xFFDCFCE7)
                            : Colors.grey[200],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Counter Desk: ${queue.location}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B192C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'NOW SERVING',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '#${queue.currentToken}',
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'WAITING IN QUEUE',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${queue.waitingCount}',
                                style: const TextStyle(
                                  color: AppTheme.secondaryNavy,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.campaign),
                          label: const Text('Call Next Token'),
                          onPressed: queue.isActive
                              ? () {
                                  // Advance queue state
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Calling Token #${queue.currentToken + 1} at ${queue.serviceName}',
                                      ),
                                      backgroundColor: AppTheme.statusAssigned,
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Re-calling Token #${queue.currentToken}',
                              ),
                            ),
                          );
                        },
                        child: const Text('Recall'),
                      ),
                    ],
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
