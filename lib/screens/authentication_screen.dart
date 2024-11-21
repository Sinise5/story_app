import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:story_app/generated/l10n.dart';
import 'package:story_app/providers/auth_provider.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({
    super.key,
  });

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final FocusNode _focusNode = FocusNode();
  late Future<void> _checkLoginFuture;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //widget.onLogin();
    _checkLoginAndTriggerCallback();
  }

  Future<void> _checkLoginAndTriggerCallback() async {
    await Future.delayed(Duration.zero, () async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkLoginStatus();

      // Hanya arahkan jika sudah login
      if (authProvider.isLoggedIn) {
        //widget.onLogin();  // Panggil callback onLogin hanya jika sudah login
        context.go('/stories'); // Arahkan ke halaman stories
      } else {
        //await authProvider.checkLoginStatus();
      }
    });
  }

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.login(_emailController.text, _passwordController.text);

      if (authProvider.isLoggedIn && mounted) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Selamat Datang')),
        );
        context.go('/stories');
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Email atau Password salah!')),
        );
      }
    } catch (error) {
      if (mounted) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Login gagal: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      key: scaffoldMessengerKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: screenHeight * 0.14,
          bottom: screenHeight * 0.05,
        ),
        child: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/sinise3.png',
                        width: screenWidth * 0.3,
                        height: screenWidth * 0.3,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    S.of(context).welcome,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    S.of(context).continuex,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Password
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return TextFormField(
                        obscureText: !authProvider.isPasswordVisible,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              authProvider.isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: authProvider.togglePasswordVisibility,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    authProvider.errorLogin,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Sign In Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _login(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.025),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              )
                            : Text(
                                S.of(context).signin,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Navigate to Register
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text(
                      S.of(context).text_signup,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
