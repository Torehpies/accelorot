import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/providers.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
	const LoginScreen({super.key});

	@override
	ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();
	bool _isLoading = false;

	Future<void> _login() async {
		setState(() => _isLoading = true);

		try {
			await ref.read(authRepositoryProvider).signIn(
				_emailController.text.trim(),
				_passwordController.text.trim(),
			);
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text("Login Failed: $e")),
			);
		} finally {
			if (mounted) setState(() => _isLoading = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		final authState = ref.watch(authStateProvider);

		return Scaffold(
			appBar: AppBar(title: const Text("Login")),
			body: authState.when(
				data: (user) {
					if (user != null) {
						return const HomeScreen();
					} else {
						return Padding(
							padding: const EdgeInsets.all(16.0),
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									TextField(
										controller: _emailController,
										decoration: const InputDecoration(labelText: "Email"),
									),
									const SizedBox(height: 12,),
									TextField(
										controller: _passwordController,
										decoration: const InputDecoration(labelText: "Password"),
										obscureText: true,
									),
									const SizedBox(height: 20,),
									_isLoading
										? const CircularProgressIndicator()
										: ElevatedButton(
											onPressed: _login, 
											child: const Text("Login"),
										),
								],
							)
						);
					}
				}
			),	
		);
	}

}

