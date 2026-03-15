import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
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
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UploadArticleBloc, UploadArticleState>(
      listener: _onStateChanged,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                    : const Text('Publish', style: TextStyle(fontWeight: FontWeight.w700)),
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
              'Thumbnail URL',
              style: TextStyle(
                color: secondaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _buildField(
              context: context,
              controller: _imageUrlController,
              hint: 'https://example.com/image.jpg',
              maxLines: 1,
              style: TextStyle(color: onSurface, fontSize: 14),
              showBorder: true,
            ),
          ],
        ),
      ),
    );
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
    if (!_formKey.currentState!.validate()) return;

    final article = ArticleEntity(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      description: _titleController.text.trim(),
      author: 'Journalist',
      urlToImage: _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : null,
      publishedAt: DateTime.now().toIso8601String().substring(0, 10),
    );

    context.read<UploadArticleBloc>().add(UploadArticle(article));
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
