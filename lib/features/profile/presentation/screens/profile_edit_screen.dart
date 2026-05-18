import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/profile_notifier.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../features/profile/domain/use_cases/get_passenger_profile_use_case.dart';
import '../../../../features/profile/domain/use_cases/update_passenger_profile_use_case.dart';
import '../../../../shared/widgets/app_message.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/primary_text_field.dart';
import '../../../../shared/widgets/skeleton.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  static const String _profileNameKey = 'profile.full_name';
  static const String _profileEmailKey = 'profile.email';
  static const String _profilePhoneKey = 'profile.phone';

  final TextEditingController _nameController = TextEditingController(text: 'John Doe');
  final TextEditingController _emailController = TextEditingController(text: 'john@example.com');
  final TextEditingController _phoneController = TextEditingController(text: '09123123123');

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  bool _isSaving = false;
  bool _isLoadingProfile = true;

  String? _avatarUrl;      // existing remote avatar
  File? _pickedImage;      // locally chosen file (not yet uploaded)

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (file == null) return;
      if (!mounted) return;
      setState(() => _pickedImage = File(file.path));
    } catch (e) {
      if (!mounted) return;
      AppMessage.error(context, 'Could not pick image. Please try again.');
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFFFE8C00)),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFFFE8C00)),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_pickedImage != null || (_avatarUrl != null && _avatarUrl!.isNotEmpty))
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _pickedImage = null;
                    _avatarUrl = null;
                  });
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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

    try {
      final profile = await getIt<UpdatePassengerProfileUseCase>().call(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarFilePath: _pickedImage?.path,
      );
      if (profile.avatarUrl != null && mounted) {
        setState(() {
          _avatarUrl = profile.avatarUrl;
          _pickedImage = null;
        });
      }

      getIt<ProfileNotifier>().update(
        name: profile.name.trim(),
        email: profile.email.trim(),
        avatarUrl: profile.avatarUrl,
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileNameKey, profile.name.trim());
      await prefs.setString(_profileEmailKey, profile.email.trim());
      await prefs.setString(_profilePhoneKey, profile.phone.trim());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Profile update failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      final String message = error is ApiException
          ? error.message
          : 'Unable to update profile. Please check your connection and try again.';
      AppMessage.error(context, message);
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    AppMessage.success(context, 'Profile updated successfully');
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(RouteNames.settings);
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await getIt<GetPassengerProfileUseCase>().call();
      if (!mounted) return;
      _nameController.text = profile.name.trim().isEmpty ? '' : profile.name.trim();
      _emailController.text = profile.email.trim().isEmpty ? '' : profile.email.trim();
      _phoneController.text = profile.phone.trim().isEmpty ? '' : profile.phone.trim();
      _avatarUrl = profile.avatarUrl;

      getIt<ProfileNotifier>().update(
        name: profile.name.trim(),
        email: profile.email.trim(),
        avatarUrl: profile.avatarUrl,
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileNameKey, profile.name.trim());
      await prefs.setString(_profileEmailKey, profile.email.trim());
      await prefs.setString(_profilePhoneKey, profile.phone.trim());
    } catch (_) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? name = prefs.getString(_profileNameKey);
      final String? email = prefs.getString(_profileEmailKey);
      final String? phone = prefs.getString(_profilePhoneKey);

      if (!mounted) return;

      if (name != null && name.trim().isNotEmpty) {
        _nameController.text = name;
      }
      if (email != null && email.trim().isNotEmpty) {
        _emailController.text = email;
      }
      if (phone != null && phone.trim().isNotEmpty) {
        _phoneController.text = phone;
      }
    }

    if (!mounted) return;
    setState(() => _isLoadingProfile = false);
  }

  Widget _buildAvatar() {
    if (_pickedImage != null) {
      return CircleAvatar(
        radius: 42,
        backgroundImage: FileImage(_pickedImage!),
      );
    }
    if (_avatarUrl != null && _avatarUrl!.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 42,
        backgroundColor: const Color(0xFFFFE3BF),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: _avatarUrl!,
            width: 84,
            height: 84,
            fit: BoxFit.cover,
            placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 2),
            errorWidget: (_, __, ___) => const Icon(
              Icons.person_rounded,
              size: 46,
              color: Color(0xFFFE8C00),
            ),
          ),
        ),
      );
    }
    return const CircleAvatar(
      radius: 42,
      backgroundColor: Color(0xFFFFE3BF),
      child: Icon(Icons.person_rounded, size: 46, color: Color(0xFFFE8C00)),
    );
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _isLoadingProfile
              ? const _ProfileEditSkeleton(key: ValueKey('profile-edit-skeleton'))
              : SingleChildScrollView(
                  key: const ValueKey('profile-edit-content'),
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildAvatar(),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Material(
                        color: const Color(0xFFFE8C00),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _isSaving ? null : _showImageSourceSheet,
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
                enabled: !_isSaving && !_isLoadingProfile,
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
                enabled: !_isSaving && !_isLoadingProfile,
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
                enabled: !_isSaving && !_isLoadingProfile,
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
                isLoading: _isSaving || _isLoadingProfile,
                onPressed: _isSaving || _isLoadingProfile ? null : _saveProfile,
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _ProfileEditSkeleton extends StatelessWidget {
  const _ProfileEditSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Center(child: SkeletonAvatar(size: 84)),
            SizedBox(height: 28),
            SkeletonText(width: 80, height: 12),
            SizedBox(height: 8),
            SkeletonBox(height: 48, borderRadius: BorderRadius.all(Radius.circular(12))),
            SizedBox(height: 18),
            SkeletonText(width: 60, height: 12),
            SizedBox(height: 8),
            SkeletonBox(height: 48, borderRadius: BorderRadius.all(Radius.circular(12))),
            SizedBox(height: 18),
            SkeletonText(width: 110, height: 12),
            SizedBox(height: 8),
            SkeletonBox(height: 48, borderRadius: BorderRadius.all(Radius.circular(12))),
            SizedBox(height: 28),
            SkeletonBox(height: 52, borderRadius: BorderRadius.all(Radius.circular(14))),
          ],
        ),
      ),
    );
  }
}
