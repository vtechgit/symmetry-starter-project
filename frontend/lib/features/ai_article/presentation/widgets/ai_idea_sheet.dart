import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/generate_article_bloc.dart';
import '../bloc/generate_article_event.dart';
import '../bloc/generate_article_state.dart';

void showAiIdeaSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider.value(
      value: context.read<GenerateArticleBloc>(),
      child: const _AiIdeaSheetContent(),
    ),
  );
}

class _AiIdeaSheetContent extends StatefulWidget {
  const _AiIdeaSheetContent();

  @override
  State<_AiIdeaSheetContent> createState() => _AiIdeaSheetContentState();
}

class _AiIdeaSheetContentState extends State<_AiIdeaSheetContent> {
  final _ideaController = TextEditingController();

  @override
  void dispose() {
    _ideaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondary = Theme.of(context).textTheme.bodyMedium!.color!;

    return BlocConsumer<GenerateArticleBloc, GenerateArticleState>(
      listener: (context, state) {
        if (state is GenerateArticleSuccess) {
          Navigator.pop(context);
        }
        if (state is GenerateArticleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is GenerateArticleLoading;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Generate with AI',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Describe your article idea and AI will write the full article.',
                style: TextStyle(color: secondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ideaController,
                maxLines: 3,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'e.g. "Climate summit 2026 outcomes and global reactions"',
                  hintStyle: TextStyle(color: secondary, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              if (isLoading) const _LoadingHint(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _onGenerate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Generate',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onGenerate() {
    final idea = _ideaController.text.trim();
    if (idea.isEmpty) return;
    context.read<GenerateArticleBloc>().add(GenerateArticleRequested(idea));
  }
}

// ── Loading hint widget ───────────────────────────────────────────────────────

class _LoadingHint extends StatefulWidget {
  const _LoadingHint();

  @override
  State<_LoadingHint> createState() => _LoadingHintState();
}

class _LoadingHintState extends State<_LoadingHint> {
  static const _messages = [
    'Gathering the latest information…',
    'Crafting your article, hang tight…',
    'The AI is thinking, almost there…',
    'Putting the finishing touches…',
    'Writing headlines and paragraphs…',
    'Your article is on its way…',
    'This may take up to a minute — worth the wait!',
    'AI generation can take up to 60 seconds…',
    'Still working — great articles need time.',
    'Almost done — this can take up to a minute.',
    'Thanks for your patience, nearly there…',
  ];

  int _index = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _index = Random().nextInt(_messages.length);
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      setState(() => _index = (_index + 1) % _messages.length);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Text(
          _messages[_index],
          key: ValueKey(_index),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
