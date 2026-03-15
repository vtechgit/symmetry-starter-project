import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/theme_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
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
          create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
        ),
      ],
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            NewsFeedPage(),
            FirestoreFeedPage(),
            SavedArticlesPage(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: _selectedIndex < 2 ? _buildFab() : null,
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onTabTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Ionicons.home_outline),
          activeIcon: Icon(Ionicons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.newspaper_outline),
          activeIcon: Icon(Ionicons.newspaper),
          label: 'Journalist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.bookmark_outline),
          activeIcon: Icon(Ionicons.bookmark),
          label: 'Bookmarks',
        ),
      ],
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/PublishArticle')
          .then((_) => setState(() => _selectedIndex = 1)),
      child: const Icon(Icons.edit_outlined),
    );
  }
}
