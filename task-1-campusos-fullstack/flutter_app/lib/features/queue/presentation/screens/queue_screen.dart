import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/queue_entity.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/queue_controller.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        context.read<QueueController>().loadQueues(
          campusId: user.campusId,
          userId: user.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final controller = context.watch<QueueController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Token Live Display (UX Spec Section 9)
          if (controller.activeToken != null) ...[
            _ActiveTokenCard(
              token: controller.activeToken!,
              queues: controller.queues,
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Available Campus Service Counters',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Join digitally to hold your place without standing in line.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (controller.isLoading && controller.queues.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.queues.length,
              itemBuilder: (context, index) {
                final queue = controller.queues[index];
                final isCurrentTokenQueue =
                    controller.activeToken?.queueId == queue.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                queue.serviceName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                queue.isActive ? 'OPEN' : 'CLOSED',
                                style: TextStyle(
                                  color: queue.isActive
                                      ? Colors.green[800]
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              backgroundColor: queue.isActive
                                  ? const Color(0xFFDCFCE7)
                                  : Colors.grey[200],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Location: ${queue.location}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _QueueStat(
                              label: 'Now Serving',
                              value: '#${queue.currentToken}',
                            ),
                            const SizedBox(width: 24),
                            _QueueStat(
                              label: 'Waiting Ahead',
                              value: '${queue.waitingCount} people',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (queue.isActive)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isCurrentTokenQueue
                                  ? null
                                  : () async {
                                      if (user != null) {
                                        await context
                                            .read<QueueController>()
                                            .joinQueue(
                                              queueId: queue.id,
                                              userId: user.id,
                                              campusId: user.campusId,
                                            );
                                      }
                                    },
                              child: Text(
                                isCurrentTokenQueue
                                    ? 'Already In Queue'
                                    : 'Join Queue',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ActiveTokenCard extends StatelessWidget {
  final QueueTokenEntity token;
  final List<QueueEntity> queues;

  const _ActiveTokenCard({required this.token, required this.queues});

  @override
  Widget build(BuildContext context) {
    final queue = queues.cast<QueueEntity?>().firstWhere(
      (q) => q?.id == token.queueId,
      orElse: () => null,
    );

    final currentServing = queue?.currentToken ?? 1;
    final peopleAhead = (token.tokenNumber - currentServing) > 0
        ? (token.tokenNumber - currentServing)
        : 0;
    final estimatedMinutes = peopleAhead * 3;

    return Card(
      color: const Color(0xFF0B192C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  queue?.serviceName ?? 'Active Queue Token',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: peopleAhead <= 2
                        ? AppTheme.accentOrange
                        : AppTheme.statusAssigned,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    peopleAhead <= 2 ? "You're Approaching!" : 'Active Token',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'YOUR TOKEN',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${token.tokenNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 48, color: Colors.grey[700]),
                Column(
                  children: [
                    const Text(
                      'NOW SERVING',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#$currentServing',
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'People Ahead: $peopleAhead',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  'Estimated: ~$estimatedMinutes mins',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueStat extends StatelessWidget {
  final String label;
  final String value;

  const _QueueStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
