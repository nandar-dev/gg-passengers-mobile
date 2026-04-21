import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_names.dart';
import '../../shared/widgets/app_message.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/primary_text_field.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'John Doe');
  final TextEditingController _emailController = TextEditingController(text: 'john@example.com');
  final TextEditingController _phoneController = TextEditingController(text: '09123123123');

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    String? nameError;
    String? emailError;
    String? phoneError;

    if (name.length < 2) {
      nameError = 'Please enter your full name';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      emailError = 'Please enter a valid email address';
    }

    if (phone.length < 8) {
      phoneError = 'Please enter a valid phone number';
    }

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _phoneError = phoneError;
    });

    return nameError == null && emailError == null && phoneError == null;
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    if (!_validate()) return;

    setState(() => _isSaving = true);

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() => _isSaving = false);

    AppMessage.success(context, 'Profile updated successfully');
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(RouteNames.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(RouteNames.settings);
          },
        ),
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: Color(0xFFFFE3BF),
                      child: Icon(
                        Icons.person_rounded,
                        size: 46,
                        color: Color(0xFFFE8C00),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Material(
                        color: const Color(0xFFFE8C00),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => AppMessage.info(context, 'Photo update will be available soon'),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              PrimaryTextField(
                label: 'Full Name',
                hint: 'John Doe',
                controller: _nameController,
                errorText: _nameError,
                enabled: !_isSaving,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_nameError != null) {
                    setState(() => _nameError = null);
                  }
                },
              ),
              const SizedBox(height: 14),
              PrimaryTextField(
                label: 'Email',
                hint: 'john@example.com',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                errorText: _emailError,
                enabled: !_isSaving,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() => _emailError = null);
                  }
                },
              ),
              const SizedBox(height: 14),
              PrimaryTextField(
                label: 'Phone Number',
                hint: '09123123123',
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                errorText: _phoneError,
                enabled: !_isSaving,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_phoneError != null) {
                    setState(() => _phoneError = null);
                  }
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save Changes',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
