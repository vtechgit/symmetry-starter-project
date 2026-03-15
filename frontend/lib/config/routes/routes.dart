import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/bloc/article/upload/upload_article_bloc.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/publish_article/publish_article.dart';
import '../../injection_container.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());

      case '/ArticleDetails':
        return _materialRoute(
          ArticleDetailsView(article: settings.arguments as ArticleEntity),
        );

      case '/PublishArticle':
        return _materialRoute(
          BlocProvider(
            create: (_) => sl<UploadArticleBloc>(),
            child: const PublishArticlePage(),
          ),
        );

      case '/Login':
        return _materialRoute(const LoginPage());

      case '/Register':
        return _materialRoute(const RegisterPage());

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
