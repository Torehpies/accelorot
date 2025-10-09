import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/screens/registration_screen.dart';
import 'package:flutter_application_1/ui/auth/view_model/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RefactoredLoginScreen extends ConsumerStatefulWidget {
  const RefactoredLoginScreen({super.key});

  @override
  ConsumerState<RefactoredLoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<RefactoredLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  void _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await ref.read(authViewModelProvider.notifier).login(email, password);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(authViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),
                const Icon(Icons.lock_outline, size: 80, color: Colors.green),
                const SizedBox(height: 20),
                const Text(
                  'Welcome back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Login to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: (v) => v != null && v.contains('@')
                      ? null
                      : 'Invalid email address',
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (v) =>
                      v != null && v.length >= 6 ? null : 'Too short',
                ),
                const SizedBox(height: 10),
                loginState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Login'),
                      ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('TODO Forgot Password')),
                    );
                  },
                  child: const Text(
                    'Forgot Password',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrationScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Don't have an account? "),
                      Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.blue,
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
      ),
    );
  }
}

    //  final theme = Theme.of(context);

    //  return Scaffold(
    //    body: Stack(
    //      children: [
    //        // Main login UI
    //        SafeArea(
    //          child: Center(
    //            child: Container(
    //              constraints: const BoxConstraints(maxWidth: 500),
    //              padding: const EdgeInsets.all(24),
    //              child: Card(
    //                elevation: 10,
    //                shape: RoundedRectangleBorder(
    //                  borderRadius: BorderRadius.circular(20),
    //                ),
    //                child: Padding(
    //                  padding: const EdgeInsets.all(32),
    //                  child: Form(
    //                    key: _controller.formKey,
    //                    child: SingleChildScrollView(
    //                      child: Column(
    //                        mainAxisSize: MainAxisSize.min,
    //                        crossAxisAlignment: CrossAxisAlignment.center,
    //                        children: [
    //                          // Logo
    //                          _buildLogo(),
    //                          const SizedBox(height: 24),
    //                          // Title
    //                          _buildTitle(theme),
    //                          const SizedBox(height: 32),
    //                          // Email Field
    //                          _buildEmailField(),
    //                          const SizedBox(height: 16),
    //                          // Password Field
    //                          _buildPasswordField(),
    //                          const SizedBox(height: 16),
    //                          // Forgot Password
    //                          _buildForgotPassword(),
    //                          const SizedBox(height: 24),
    //                          // Login Button
    //                          _buildLoginButton(),
    //                          const SizedBox(height: 24),
    //                          // Sign Up Link
    //                          _buildSignUpLink(),
    //                        ],
    //                      ),
    //                    ),
    //                  ),
    //                ),
    //              ),
    //            ),
    //          ),
    //        ),
    //        // Button at top right for Admin Panel
    //        Positioned(
    //          top: 24,
    //          right: 24,
    //          child: IconButton(
    //            icon: const Icon(
    //              Icons.admin_panel_settings,
    //              color: Colors.white,
    //              size: 28,
    //            ),
    //            style: IconButton.styleFrom(
    //              backgroundColor: Colors.teal,
    //              shape: const CircleBorder(),
    //              padding: const EdgeInsets.all(12),
    //              shadowColor: Colors.black.withValues(alpha: 0.08),
    //              elevation: 8,
    //            ),
    //            onPressed: () {
    //              Navigator.pushReplacement(
    //                context,
    //                MaterialPageRoute(
    //                  builder: (context) => const AdminMainNavigation(),
    //                ),
    //              );
    //            },
    //          ),
    //        ),
    //        // Button at top left for Home
    //        Positioned(
    //          top: 24,
    //          left: 24,
    //          child: IconButton(
    //            icon: const Icon(Icons.home, color: Colors.white, size: 28),
    //            style: IconButton.styleFrom(
    //              backgroundColor: Colors.teal,
    //              shape: const CircleBorder(),
    //              padding: const EdgeInsets.all(12),
    //              shadowColor: Colors.black.withValues(alpha: 0.08),
    //              elevation: 8,
    //            ),
    //            onPressed: () {
    //              Navigator.pushReplacement(
    //                context,
    //                MaterialPageRoute(
    //                  builder: (context) => const MainNavigation(),
    //                ),
    //              );
    //            },
    //          ),
    //        ),
    //      ],
    //    ),
    //  );
    //}

    //Widget _buildLogo() {
    //  return Container(
    //    width: 80,
    //    height: 80,
    //    decoration: BoxDecoration(
    //      gradient: LinearGradient(
    //        colors: [Colors.teal.shade400, Colors.teal.shade700],
    //        begin: Alignment.topLeft,
    //        end: Alignment.bottomRight,
    //      ),
    //      shape: BoxShape.circle,
    //      boxShadow: [
    //        BoxShadow(
    //          color: Colors.teal..withValues(alpha: 0.3),
    //          blurRadius: 15,
    //          offset: const Offset(0, 5),
    //        ),
    //      ],
    //    ),
    //    child: const Icon(Icons.trending_up, size: 36, color: Colors.white),
    //  );
    //}

    //Widget _buildTitle(ThemeData theme) {
    //  return Column(
    //    children: [
    //      Text(
    //        'Welcome Back!',
    //        style: TextStyle(
    //          fontSize: 28,
    //          fontWeight: FontWeight.bold,
    //          color: theme.primaryColor,
    //        ),
    //      ),
    //      const SizedBox(height: 8),
    //      Text(
    //        'Sign in to continue',
    //        style: TextStyle(fontSize: 16, color: theme.hintColor),
    //      ),
    //    ],
    //  );
    //}

    //Widget _buildEmailField() {
    //  return TextFormField(
    //    controller: _controller.emailController,
    //    keyboardType: TextInputType.emailAddress,
    //    textInputAction: TextInputAction.next,
    //    decoration: InputDecoration(
    //      labelText: 'Email Address',
    //      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    //    ),
    //    validator: _controller.validateEmail,
    //  );
    //}

    //Widget _buildPasswordField() {
    //  return TextFormField(
    //    controller: _controller.passwordController,
    //    obscureText: _controller.obscurePassword,
    //    textInputAction: TextInputAction.done,
    //    onFieldSubmitted: (_) => _controller.loginUser(),
    //    decoration: InputDecoration(
    //      labelText: 'Password',
    //      suffixIcon: IconButton(
    //        icon: Icon(
    //          _controller.obscurePassword
    //              ? Icons.visibility_outlined
    //              : Icons.visibility_off_outlined,
    //          color: Colors.grey,
    //        ),
    //        onPressed: _controller.togglePasswordVisibility,
    //      ),
    //      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    //    ),
    //    validator: _controller.validatePassword,
    //  );
    //}

    //Widget _buildForgotPassword() {
    //  return Align(
    //    alignment: Alignment.centerRight,
    //    child: TextButton(
    //      onPressed: _controller.handleForgotPassword,
    //      child: const Text('Forgot Password?'),
    //    ),
    //  );
    //}

    //Widget _buildLoginButton() {
    //  return SizedBox(
    //    width: double.infinity,
    //    child: ElevatedButton(
    //      onPressed: _controller.isLoading ? null : _controller.loginUser,
    //      style: ElevatedButton.styleFrom(
    //        backgroundColor: Colors.teal,
    //        foregroundColor: Colors.white,
    //        padding: const EdgeInsets.symmetric(vertical: 16),
    //        shape: RoundedRectangleBorder(
    //          borderRadius: BorderRadius.circular(12),
    //        ),
    //        elevation: 4,
    //      ),
    //      child: _controller.isLoading
    //          ? const SizedBox(
    //              width: 20,
    //              height: 20,
    //              child: CircularProgressIndicator(
    //                strokeWidth: 2,
    //                valueColor: AlwaysStoppedAnimation(Colors.white),
    //              ),
    //            )
    //          : const Text(
    //              'Sign In',
    //              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    //            ),
    //    ),
    //  );
    //}

    //Widget _buildSignUpLink() {
    //  return Row(
    //    mainAxisAlignment: MainAxisAlignment.center,
    //    children: [
    //      const Text("Don't have an account? "),
    //      TextButton(
    //        onPressed: () {
    //          Navigator.pushReplacement(
    //            context,
    //            MaterialPageRoute(
    //              builder: (context) => const RegistrationScreen(),
    //            ),
    //          );
    //        },
    //        child: const Text(
    //          "Sign up",
    //          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
    //        ),
    //      ),
    //    ],
    //  );
    //}
//  }
//}
