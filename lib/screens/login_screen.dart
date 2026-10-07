import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/glass_container.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'student@viva.edu');
  final _passwordController = TextEditingController(text: 'weather123');

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final res = _isSignUp
        ? await FirebaseService.register(
            email: _emailController.text,
            password: _passwordController.text,
          )
        : await FirebaseService.signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );

    setState(() => _isLoading = false);

    if (res['success'] == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSignUp ? 'Account created! Welcome.' : 'Signed in successfully!'),
          backgroundColor: Colors.teal.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _goToHome();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['error'] ?? 'Authentication failed'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    await FirebaseService.signInAsGuest();
    setState(() => _isLoading = false);
    if (mounted) _goToHome();
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF141E30),
              Color(0xFF243B55),
              Color(0xFF0F2027),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Logo & Branding
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(
                        Icons.cloud_queue_rounded,
                        size: 54,
                        color: Color(0xFF00D2FF),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _isSignUp ? 'Create AeroCast Account' : 'Welcome to AeroCast',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Firebase Authentication & Cloud Storage Portal',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Auth Glass Card
                    GlassContainer(
                      padding: const EdgeInsets.all(22.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                              hintText: 'student@example.com',
                            ),
                            validator: (val) {
                              if (val == null || !val.contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.white60,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Submit Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D2FF),
                              foregroundColor: const Color(0xFF0B131E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : Text(
                                    _isSignUp ? 'Sign Up with Firebase' : 'Sign In with Firebase',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                          const SizedBox(height: 14),

                          // Toggle Sign In / Sign Up
                          TextButton(
                            onPressed: () {
                              setState(() => _isSignUp = !_isSignUp);
                            },
                            child: Text(
                              _isSignUp
                                  ? 'Already have an account? Sign In'
                                  : "Don't have an account? Sign Up",
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Guest Mode Button
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGuestLogin,
                      icon: const Icon(Icons.bolt, color: Colors.amberAccent),
                      label: const Text(
                        'Continue as Guest / Evaluator Mode',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
