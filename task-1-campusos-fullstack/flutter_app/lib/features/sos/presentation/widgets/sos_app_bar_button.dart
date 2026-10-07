import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/sos_controller.dart';
import 'sos_emergency_dialog.dart';

class SosAppBarButton extends StatefulWidget {
  const SosAppBarButton({super.key});

  @override
  State<SosAppBarButton> createState() => _SosAppBarButtonState();
}

class _SosAppBarButtonState extends State<SosAppBarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sos = context.watch<SosController>();
    final isAlertActive = sos.isEmergencyActive;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isAlertActive
                ? const Color(0xFFB91C1C)
                : const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isAlertActive ? Colors.yellow : Colors.white,
                width: 1.5,
              ),
            ),
          ),
          icon: Icon(
            isAlertActive ? Icons.warning_amber_rounded : Icons.sos,
            size: 20,
            color: Colors.white,
          ),
          label: Text(
            isAlertActive ? 'ACTIVE SOS' : 'SOS',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              fontSize: 13,
            ),
          ),
          onPressed: () {
            SosEmergencyDialog.show(context);
          },
        ),
      ),
    );
  }
}
