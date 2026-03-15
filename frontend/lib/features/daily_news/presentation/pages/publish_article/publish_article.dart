import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/widgets/app_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/ai_article/presentation/bloc/generate_article_bloc.dart';
import 'package:news_app_clean_architecture/features/ai_article/presentation/bloc/generate_article_state.dart';
import 'package:news_app_clean_architecture/features/ai_article/presentation/widgets/ai_idea_sheet.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/upload/upload_article_bloc.dart';
import '../../bloc/article/upload/upload_article_event.dart';
import '../../bloc/article/upload/upload_article_state.dart';

class PublishArticlePage extends StatefulWidget {
  const PublishArticlePage({Key? key}) : super(key: key);

  @override
  State<PublishArticlePage> createState() => _PublishArticlePageState();
}

class _PublishArticlePageState extends State<PublishArticlePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Uint8List? _pickedImageBytes;
  String? _pickedImageFileName;
  String? _aiImageUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GenerateArticleBloc>(
      create: (_) => sl<GenerateArticleBloc>(),
      child: BlocListener<UploadArticleBloc, UploadArticleState>(
        listener: _onStateChanged,
        child: Builder(
          builder: (ctx) => BlocListener<GenerateArticleBloc, GenerateArticleState>(
            listener: _onAiStateChanged,
            child: Scaffold(
              appBar: _buildAppBar(ctx),
              body: _buildBody(ctx),
            ),
          ),
        ),
      ),
    );
  }

  void _onAiStateChanged(BuildContext context, GenerateArticleState state) {
    if (state is GenerateArticleSuccess) {
      _titleController.text = state.article.title;
      _descriptionController.text = state.article.description;
      _contentController.text = state.article.content;
      setState(() {
        _pickedImageBytes = null;
        _pickedImageFileName = null;
        _aiImageUrl = state.article.thumbnailUrl;
      });
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final dividerColor = Theme.of(context).dividerColor;
    return AppBar(
      backgroundColor: scaffoldColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(Ionicons.chevron_back, color: onSurface),
      ),
      title: Text(
        'New Article',
        style: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
      ),
      actions: [
        BlocBuilder<UploadArticleBloc, UploadArticleState>(
          builder: (context, state) {
            final isLoading = state is UploadArticleLoading;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _onPublish(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Publish',
                        style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: dividerColor),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
    final dividerColor = Theme.of(context).dividerColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAiButton(context),
            const SizedBox(height: 12),
            _buildField(
              context: context,
              controller: _titleController,
              hint: 'Write your title here...',
              maxLines: 2,
              style: TextStyle(
                color: onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              showBorder: false,
            ),
            Divider(color: dividerColor),
            const SizedBox(height: 4),
            _buildField(
              context: context,
              controller: _descriptionController,
              hint: 'Short summary of your article...',
              maxLines: 2,
              style: TextStyle(
                color: secondaryColor,
                fontSize: 15,
                height: 1.5,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Description is required'
                  : null,
              showBorder: false,
            ),
            Divider(color: dividerColor),
            const SizedBox(height: 8),
            _buildField(
              context: context,
              controller: _contentController,
              hint: 'Add your article here...',
              maxLines: 12,
              style: TextStyle(color: onSurface, fontSize: 16, height: 1.6),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Content is required' : null,
              showBorder: false,
            ),
            Divider(color: dividerColor),
            const SizedBox(height: 16),
            Text(
              'Thumbnail *',
              style: TextStyle(
                color: secondaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _buildImagePicker(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAiButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: () => showAiIdeaSheet(context),
      icon: Icon(Icons.auto_awesome, size: 16, color: colorScheme.primary),
      label: Text(
        'Generate with AI',
        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;

    final hasImage = _pickedImageBytes != null || _aiImageUrl != null;
    if (hasImage) {
      final imageWidget = _pickedImageBytes != null
          ? Image.memory(_pickedImageBytes!, width: double.infinity, height: 180, fit: BoxFit.cover)
          : AppNetworkImage(url: _aiImageUrl!, width: double.infinity, height: 180);
      return GestureDetector(
        onTap: _pickImage,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              imageWidget,
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Ionicons.image_outline,
                          color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Change',
                          style:
                              TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FormField<Uint8List>(
      validator: (_) =>
          (_pickedImageBytes == null && _aiImageUrl == null) ? 'Thumbnail is required' : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(
                  color: field.hasError ? Colors.red : dividerColor,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Ionicons.image_outline,
                      color: secondaryColor, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to select thumbnail',
                    style: TextStyle(color: secondaryColor, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG, WebP — max 5 MB',
                    style: TextStyle(color: secondaryColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                field.errorText!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    setState(() {
      _pickedImageBytes = file.bytes;
      _pickedImageFileName = '${timestamp}_$safeName';
    });
  }

  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    required TextStyle style,
    String? Function(String?)? validator,
    required bool showBorder,
  }) {
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: style,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: secondaryColor),
        border: showBorder ? null : InputBorder.none,
        enabledBorder: showBorder ? null : InputBorder.none,
        focusedBorder: showBorder ? null : InputBorder.none,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  void _onPublish(BuildContext context) {
    final formValid = _formKey.currentState!.validate();
    if (!formValid || (_pickedImageBytes == null && _aiImageUrl == null)) return;

    final authState = context.read<AuthBloc>().state;
    final email = authState is AuthAuthenticated ? authState.user.email ?? '' : '';
    final author = authState is AuthAuthenticated
        ? (authState.user.displayName?.isNotEmpty == true
            ? authState.user.displayName!
            : email.split('@').first)
        : 'Anonymous';

    final article = ArticleEntity(
      title: _titleController.text.trim(),
      author: author,
      authorPhotoURL: authState is AuthAuthenticated ? authState.user.photoURL : null,
      description: _descriptionController.text.trim(),
      content: _contentController.text.trim(),
      publishedAt: DateTime.now().toIso8601String().substring(0, 10),
    );

    context.read<UploadArticleBloc>().add(
          UploadArticle(
            article,
            imageBytes: _pickedImageBytes,
            imageFileName: _pickedImageFileName,
            imageUrl: _aiImageUrl,
          ),
        );
  }

  void _onStateChanged(BuildContext context, UploadArticleState state) {
    if (state is UploadArticleDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article published successfully!')),
      );
      Navigator.pop(context);
    }
    if (state is UploadArticleError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }
}
