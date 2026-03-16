import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/ai_chat/presentation/bloc/ai_chat_bloc.dart';
import 'package:news_app_clean_architecture/features/ai_chat/presentation/bloc/ai_chat_event.dart';
import 'package:news_app_clean_architecture/features/ai_chat/presentation/bloc/ai_chat_state.dart';
import 'package:news_app_clean_architecture/features/ai_chat/presentation/widgets/chat_bubble.dart';
import 'package:news_app_clean_architecture/features/ai_chat/presentation/widgets/chat_input_bar.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({Key? key}) : super(key: key);

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return _buildSignInPrompt(context);
        }
        return _buildChatBody(context);
      },
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Ionicons.chatbubble_ellipses_outline,
              color: secondaryColor, size: 48),
          const SizedBox(height: 12),
          Text(
            'Sign in to use AI Chat',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your conversation is linked to your account',
            style: TextStyle(color: secondaryColor, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/Login'),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBody(BuildContext context) {
    return BlocConsumer<AiChatBloc, AiChatState>(
      listener: (context, state) {
        if (state is AiChatStreaming || state is AiChatReady) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        final isStreaming = state is AiChatStreaming;
        return Column(
          children: [
            if (state is AiChatError) _buildErrorBanner(context, state),
            Expanded(
              child: state.messages.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      itemCount: state.messages.length,
                      itemBuilder: (_, index) =>
                          ChatBubble(message: state.messages[index]),
                    ),
            ),
            ChatInputBar(
              enabled: !isStreaming,
              onSend: (text) =>
                  context.read<AiChatBloc>().add(AiChatMessageSent(text)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorBanner(BuildContext context, AiChatError state) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.error.withValues(alpha: 0.12),
      child: Text(
        'Error: ${state.errorMessage}',
        style: TextStyle(color: colorScheme.error, fontSize: 13),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Ionicons.chatbubble_ellipses_outline,
              color: secondaryColor, size: 48),
          const SizedBox(height: 12),
          Text(
            'Ask me anything about the news',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "I'm your AI journalist assistant",
            style: TextStyle(color: secondaryColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
