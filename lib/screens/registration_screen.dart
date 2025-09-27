// lib/screens/registration_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import '../models/appuser.dart';
import '../controllers/register_controller.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
	final _controller = RegisterController();
  final _formKey = GlobalKey<FormState>();

  final _firstNameController= TextEditingController();
  final _lastNameController= TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? selectedRole = 'User';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;
	// TODO: use _registeredUser for profile or passing data chuchu
	AppUser? _registeredUser;

	void _handleRegister() async {
		if (!_formKey.currentState!.validate()) {
			return;
		} setState(() => _isLoading = true);
		try {
			String fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

			final user = await _controller.register(
				fullName: fullName,
				email: _emailController.text.trim(),
				password: _passwordController.text.trim() 
			);

			setState(() => _registeredUser = user);

			if (!mounted) return;

			if (user != null) {
				Navigator.pushReplacement(
					context, 
					MaterialPageRoute(builder: (context) => const HomeScreen()),
				);

				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text("Welcome $fullName")),
				);
			}

		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text("Registration failed: $e")),
			);
		} finally {
			setState(() => _isLoading = false);
		}
	}

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 10,
              //shape: RoundedRectangleBorder(
              //  borderRadius: BorderRadius.circular(20),
              //),
              child: Padding(
                padding: const EdgeInsets.all(32),
								child: SingleChildScrollView(
									child: ConstrainedBox(
										constraints: BoxConstraints(
											minHeight: MediaQuery.of(context).size.height * 0.7,
									),
									child: IntrinsicHeight(
										child: Form(
											key: _formKey,
											child: Column(
												mainAxisSize: MainAxisSize.min,
												crossAxisAlignment: CrossAxisAlignment.center,
												children: [
													// Logo
													Container(
													  width: 80,
													  height: 80,
													  decoration: BoxDecoration(
													    gradient: LinearGradient(
													      colors: [
													        Colors.teal.shade400,
													        Colors.teal.shade700,
													      ],
													      begin: Alignment.topLeft,
													      end: Alignment.bottomRight,
													    ),
													    shape: BoxShape.circle,
													    boxShadow: [
													      BoxShadow(
													        color: Colors.teal.withValues(alpha: 0.5),
													        blurRadius: 15,
													        offset: const Offset(0, 5),
													      ),
													    ],
													  ),
													  child: const Icon(
													    Icons.trending_up,
													    size: 36,
													    color: Colors.white,
													  ),
													),
													Text(
														'Create Account',
														style: TextStyle(
															fontSize: 28,
															fontWeight: FontWeight.bold,
															color: theme.primaryColor,
														),
													),
													Text(
														'Join us to get started',
														style: TextStyle(
															fontSize: 16, 
															color: theme.hintColor,
														),
													),
													const SizedBox(height: 4),
													
													// First Name Field
													TextFormField(
														controller: _firstNameController,
														textInputAction: TextInputAction.next,
														decoration: InputDecoration(
															labelText: 'First Name',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
															),
														),
														validator: (value) => value == null || value.isEmpty 
																? 'Name is required' 
																: null,
													),
													const SizedBox(height: 8),

													// Last Name Field
													TextFormField(
														controller: _lastNameController,
														textInputAction: TextInputAction.next,
														decoration: InputDecoration(
															labelText: 'Last Name',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
															),
														),
														validator: (value) => value == null || value.isEmpty 
																? 'Name is required' 
																: null,
													),

													const SizedBox(height: 8),
													// Email Field
													TextFormField(
														controller: _emailController,
														keyboardType: TextInputType.emailAddress,
														textInputAction: TextInputAction.next,
														decoration: InputDecoration(
															labelText: 'Email Address',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
															),
														),
														validator: (value) {
															if (value == null || value.isEmpty) return 'Email is required';
															if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
																return 'Enter a valid email address';
															}
															return null;
														},
													),
													const SizedBox(height: 8),

													// Password Field
													TextFormField(
														controller: _passwordController,
														obscureText: _obscurePassword,
														textInputAction: TextInputAction.next,
														decoration: InputDecoration(
															labelText: 'Password',
															suffixIcon: IconButton(
																icon: Icon(
																	_obscurePassword 
																			? Icons.visibility_outlined 
																			: Icons.visibility_off_outlined,
																	color: Colors.grey,
																),
																onPressed: () {
																	setState(() {
																		_obscurePassword = !_obscurePassword;
																	});
																},
															),
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
															),
														),
														validator: (value) {
															if (value == null || value.isEmpty) return 'Password is required';
															if (value.length < 6) return 'Password must be at least 6 characters';
															return null;
														},
													),
													const SizedBox(height: 8),

													// Confirm Password Field
													TextFormField(
														controller: _confirmPasswordController,
														obscureText: _obscureConfirmPassword,
														textInputAction: TextInputAction.done,
														decoration: InputDecoration(
															labelText: 'Confirm Password',
															suffixIcon: IconButton(
																icon: Icon(
																	_obscureConfirmPassword 
																			? Icons.visibility_outlined 
																			: Icons.visibility_off_outlined,
																	color: Colors.grey,
																),
																onPressed: () {
																	setState(() {
																		_obscureConfirmPassword = !_obscureConfirmPassword;
																	});
																},
															),
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
															),
														),
														validator: (value) {
															if (value == null || value.isEmpty) return 'Please confirm your password';
															if (value != _passwordController.text) return 'Passwords do not match';
															return null;
														},
													),
													const SizedBox(height: 2),

													// Role Dropdown
													//DropdownButtonFormField<String>(
													//  initialValue: selectedRole,
													//  decoration: InputDecoration(
													//    labelText: 'Select Role',
													//    border: OutlineInputBorder(
													//      borderRadius: BorderRadius.circular(12),
													//    ),
													//  ),
													//  items: ['User', 'Admin'].map((String role) {
													//    return DropdownMenuItem<String>(
													//      value: role,
													//      child: Text(role),
													//    );
													//  }).toList(),
													//  onChanged: (value) {
													//    setState(() {
													//      selectedRole = value;
													//    });
													//  },
													//  validator: (value) => value == null ? 'Please select a role' : null,
													//),
													_isLoading
														? const CircularProgressIndicator()
														: ElevatedButton(
															onPressed: _handleRegister,
															child: const Text("Register"),
															),

													// Sign In Link
													Row(
														mainAxisAlignment: MainAxisAlignment.center,
														children: [
															const Text("Already have an account? "),
															TextButton(
																onPressed: () {
																	Navigator.pushReplacement(
																		context,
																		MaterialPageRoute(builder: (context) => const LoginScreen()),
																	);
																},
																child: const Text(
																	"Sign in",
																	style: TextStyle(
																		color: Colors.teal,
																		fontWeight: FontWeight.bold,
																		),
																	),
																),
															],
														),
													],
												),
											),
										),
									),
								),
							),
						),
					),
				),
			),
    );
  }
}
