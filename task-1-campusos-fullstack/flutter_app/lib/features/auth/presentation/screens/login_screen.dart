import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:campusos/core/theme/app_theme.dart';
import 'package:campusos/features/sos/presentation/widgets/sos_emergency_dialog.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'student@campus.edu');
  final _passwordController = TextEditingController(text: 'password123');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      if (auth.currentUser?.isAdmin == true) {
        context.go('/admin/dashboard');
      } else {
        context.go('/student/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 860 : 440),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.creamBorder, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: isDesktop
                  ? Row(
                      children: [
                        // Left Branding Showcase Banner
                        Expanded(
                          flex: 5,
                          child: Container(
                            padding: const EdgeInsets.all(40),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF0F1E36),
                                  Color(0xFF1E3A8A),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.school,
                                    size: 38,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'CampusOS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Intelligent Campus Operating System & Safety Dispatch Layer',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                _buildFeatureBullet(
                                  icon: Icons.check_circle_outline,
                                  text: 'Instant CampusFix maintenance reporting',
                                ),
                                const SizedBox(height: 12),
                                _buildFeatureBullet(
                                  icon: Icons.search_outlined,
                                  text: 'AI-assisted Lost & Found recovery',
                                ),
                                const SizedBox(height: 12),
                                _buildFeatureBullet(
                                  icon: Icons.bolt,
                                  text: '24/7 Rapid SOS Emergency response',
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.campusGreenDark.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppTheme.campusGreenBorder.withOpacity(0.4),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: AppTheme.campusGreenBorder,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'All Campus Node Services Active',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right Form
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: _buildForm(context, auth),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: _buildForm(context, auth),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBullet({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.campusGreenBorder),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, AuthController auth) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.softBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Portal Sign In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryNavy,
                    ),
                  ),
                  Text(
                    'Enter your university credentials',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (auth.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.emergencyRedLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.emergencyRedBorder),
              ),
              child: Text(
                auth.errorMessage!,
                style: const TextStyle(
                  color: AppTheme.emergencyRed,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Campus Email',
              hintText: 'student@campus.edu',
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryBlue),
            ),
            validator: (value) =>
                (value == null || !value.contains('@'))
                    ? 'Enter a valid campus email'
                    : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryBlue),
            ),
            validator: (value) =>
                (value == null || value.length < 6)
                    ? 'Password must be 6+ chars'
                    : null,
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: auth.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: auth.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Sign In to CampusOS',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Quick Test Profiles:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _emailController.text = 'student@campus.edu';
                      _passwordController.text = 'password123';
                    });
                  },
                  icon: const Icon(Icons.school, size: 16, color: AppTheme.primaryBlue),
                  label: const Text('Student Demo', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _emailController.text = 'admin@campus.edu';
                      _passwordController.text = 'password123';
                    });
                  },
                  icon: const Icon(Icons.admin_panel_settings, size: 16, color: AppTheme.campusGreenDark),
                  label: const Text('Admin Demo', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppTheme.creamBorder),
          const SizedBox(height: 10),
          // Immediate SOS Access Link
          Center(
            child: TextButton.icon(
              onPressed: () => SosEmergencyDialog.show(context),
              icon: const Icon(Icons.sos, color: AppTheme.emergencyRed, size: 20),
              label: const Text(
                'Campus Emergency SOS Helpline',
                style: TextStyle(
                  color: AppTheme.emergencyRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
