import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/upload_profile_photo_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _photoURL;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _photoURL = user?.photoURL;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is AuthAuthenticated) {
          setState(() => _photoURL = state.user.photoURL);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isSaving = authState is AuthLoading;
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : _onSave,
                  child: isSaving
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  _buildAvatar(colorScheme),
                  const SizedBox(height: 32),
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildEmailField(),
                  const SizedBox(height: 40),
                  _buildLogoutButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
    final displayName = _nameController.text;
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: _isUploading ? null : _pickAndUploadPhoto,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipOval(
            child: SizedBox(
              width: 96,
              height: 96,
              child: _photoURL != null
                  ? CachedNetworkImage(
                      imageUrl: _photoURL!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: colorScheme.primary),
                      errorWidget: (_, __, ___) =>
                          _avatarFallback(colorScheme, initial),
                    )
                  : _avatarFallback(colorScheme, initial),
            ),
          ),
          if (_isUploading)
            ClipOval(
              child: Container(
                width: 96,
                height: 96,
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 2),
            ),
            child:
                const Icon(Icons.camera_alt, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(ColorScheme colorScheme, String initial) {
    return Container(
      color: colorScheme.primary,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Display name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.person_outline),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.email_outlined),
        fillColor: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        filled: true,
      ),
      style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () =>
            context.read<AuthBloc>().add(const AuthSignedOut()),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Log out'),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.first.bytes == null) return;

    final file = result.files.first;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isUploading = true);

    final uploadResult = await sl<UploadProfilePhotoUseCase>().call(
      UploadProfilePhotoParams(
        bytes: file.bytes!,
        uid: authState.user.uid,
        fileName: file.name,
      ),
    );

    if (mounted) {
      setState(() {
        _isUploading = false;
        if (uploadResult.data != null) {
          _photoURL = uploadResult.data;
        }
      });
      if (uploadResult.data != null) {
        context.read<AuthBloc>().add(ProfileUpdateRequested(photoURL: uploadResult.data));
      }
    }
  }

  void _onSave() {
    final name = _nameController.text.trim();
    context.read<AuthBloc>().add(ProfileUpdateRequested(
          displayName: name.isEmpty ? null : name,
          photoURL: _photoURL,
        ));
  }
}
