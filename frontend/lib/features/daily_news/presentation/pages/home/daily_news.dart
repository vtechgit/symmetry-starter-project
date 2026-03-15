import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/theme_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_state.dart';
import 'package:news_app_clean_architecture/core/utils/auth_guard.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/bookmark/bookmark_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/bookmark/bookmark_event.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_article/saved_article.dart';
import 'firestore_feed_page.dart';
import 'news_feed_page.dart';

class DailyNews extends StatefulWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  int _selectedIndex = 0;

  static const _titles = ['For You', 'Journalist', 'Bookmarks'];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<FirestoreArticlesBloc>()..add(const GetFirestoreArticles()),
        ),
        BlocProvider(
          create: (_) => sl<BookmarkBloc>()..add(const GetBookmarks()),
        ),
      ],
      child: Builder(
        builder: (innerCtx) => Scaffold(
          appBar: _buildAppBar(context),
          body: IndexedStack(
            index: _selectedIndex,
            children: const [
              NewsFeedPage(),
              FirestoreFeedPage(),
              SavedArticlesPage(),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(innerCtx),
          floatingActionButton: _selectedIndex < 2 ? _buildFab() : null,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;
    return AppBar(
      backgroundColor: isDark ? XColors.black : XLightColors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        _titles[_selectedIndex],
        style: TextStyle(
          color: isDark ? XColors.textPrimary : XLightColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: isDark ? XColors.textPrimary : XLightColors.textPrimary,
          ),
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final isLoggedIn = authState is AuthAuthenticated;
            return IconButton(
              icon: Icon(
                isLoggedIn ? Icons.person : Icons.person_outline,
                color: isDark ? XColors.textPrimary : XLightColors.textPrimary,
              ),
              onPressed: () {
                if (isLoggedIn) {
                  context.read<AuthBloc>().add(const AuthSignedOut());
                } else {
                  Navigator.pushNamed(context, '/Login');
                }
              },
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          height: 0.5,
          color: isDark ? XColors.border : XLightColors.border,
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final firestoreState = context.watch<FirestoreArticlesBloc>().state;
    final articleCount = firestoreState is FirestoreArticlesDone
        ? (firestoreState.articles?.length ?? 0)
        : 0;

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (index == 2) {
          context.read<BookmarkBloc>().add(const GetBookmarks());
        }
        _onTabTapped(index);
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Ionicons.home_outline),
          activeIcon: Icon(Ionicons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: articleCount > 0,
            label: Text('$articleCount'),
            child: const Icon(Ionicons.newspaper_outline),
          ),
          activeIcon: const Icon(Ionicons.newspaper),
          label: 'Journalist',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Ionicons.bookmark_outline),
          activeIcon: Icon(Ionicons.bookmark),
          label: 'Bookmarks',
        ),
      ],
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => requireAuth(context, () {
        Navigator.pushNamed(context, '/PublishArticle')
            .then((_) => setState(() => _selectedIndex = 1));
      }),
      child: const Icon(Icons.edit_outlined),
    );
  }
}
