import 'package:clash_clock/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String errorMessage = '';
  bool isLoading = false;

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  void register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
      
      try {
        await authService.value.createAccount(
          email: controllerEmail.text,
          password: controllerPassword.text,
        );
        
        // Verify registration success by checking currentUser
        if (authService.value.currentUser != null) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful!')),
            );
            
            Navigator.of(context).pop();
          }
        } else {
          // This should not happen normally, but handle it just in case
          setState(() {
            isLoading = false;
            errorMessage = 'Registration failed. Please try again.';
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
          errorMessage = e.message ?? 'Registration failed. Please try again.';
        });
        
        print('FirebaseAuthException: ${e.code} - ${e.message}');
      } catch (e) {
        print('Error during registration: $e');
        
        // Special handling for PigeonUserDetails conversion error
        if (e.toString().contains('PigeonUserDetails') && authService.value.currentUser != null) {
          // Despite the error, if currentUser is not null, registration succeeded
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful!')),
            );
            
            Navigator.of(context).pop();
          }
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'An unexpected error occurred. Please try again.';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: controllerEmail,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Add basic email validation
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: controllerPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              isLoading 
                ? CircularProgressIndicator() 
                : ElevatedButton(
                    onPressed: register,
                    child: Text(
                      'Register',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

