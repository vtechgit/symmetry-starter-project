import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

void requireAuth(BuildContext context, VoidCallback action) {
  if (context.read<AuthBloc>().state is AuthAuthenticated) {
    action();
  } else {
    Navigator.pushNamed(context, '/Login');
  }
}
