import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _name = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = ref.read(authServiceProvider);
      if (_isLogin) {
        await service.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await service.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _name,
        );
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(authServiceProvider);
      await service.signInWithGoogle();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _guestMode() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(authServiceProvider);
      await service.signInAsGuest();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text(
                  _isLogin ? 'Welcome back' : 'Create account',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Sign in to continue'
                      : 'Start creating amazing videos',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),
                if (!_isLogin) ...[
                  CustomTextField(
                    hint: 'Your name',
                    prefix: const Icon(Icons.person_outline),
                    onChanged: (v) => _name = v,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                CustomTextField(
                  hint: 'Email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hint: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefix: const Icon(Icons.lock_outline),
                  suffix: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter password';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  label: _isLogin ? 'Sign In' : 'Create Account',
                  onTap: _submit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  label: 'Continue with Google',
                  onTap: _googleSignIn,
                  isOutlined: true,
                  icon: Icons.g_mobiledata,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  label: 'Continue as Guest',
                  onTap: _guestMode,
                  isOutlined: true,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? 'New here? Create an account'
                          : 'Already have an account? Sign in',
                    ),
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
