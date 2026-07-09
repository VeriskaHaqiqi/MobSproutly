import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';

class ArticleProvider extends ChangeNotifier {
  final ArticleService _articleService = ArticleService();

  List<Article> _articles = [];
  List<Article> _bookmarkedArticles = [];
  List<ArticleCategory> _categories = [];
  List<Article> _myArticles = [];

  bool _isLoading = false;
  bool _isBookmarksLoading = false;
  bool _isCategoriesLoading = false;
  bool _isActionLoading = false;

  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _myCurrentPage = 1;
  int _myLastPage = 1;

  // Getters
  List<Article> get articles => _articles;
  List<Article> get bookmarkedArticles => _bookmarkedArticles;
  List<ArticleCategory> get categories => _categories;
  List<Article> get myArticles => _myArticles;

  bool get isLoading => _isLoading;
  bool get isBookmarksLoading => _isBookmarksLoading;
  bool get isCategoriesLoading => _isCategoriesLoading;
  bool get isActionLoading => _isActionLoading;

  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;

  // Fetch articles
  Future<void> fetchArticles(
      {int page = 1,
      int? categoryId,
      String? search,
      bool refresh = false}) async {
    if (page == 1 || refresh) {
      _articles.clear();
      _currentPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _articleService.getArticles(
      page: page,
      categoryId: categoryId,
      search: search,
    );

    _isLoading = false;

    if (result['success']) {
      final List<Article> fetched = result['articles'];
      _articles.addAll(fetched);
      _currentPage = page;
      _lastPage = result['lastPage'];
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
  }

  // Fetch categories
  Future<void> fetchCategories() async {
    if (_categories.isNotEmpty) return; // cache

    _isCategoriesLoading = true;
    notifyListeners();

    final result = await _articleService.getCategories();
    _isCategoriesLoading = false;

    if (result['success']) {
      _categories = result['categories'];
    }
    notifyListeners();
  }

  // Fetch bookmarks
  Future<void> fetchBookmarks({int page = 1, bool refresh = false}) async {
    if (page == 1 || refresh) {
      _bookmarkedArticles.clear();
    }

    _isBookmarksLoading = true;
    notifyListeners();

    final result = await _articleService.getBookmarkedArticles(page: page);
    _isBookmarksLoading = false;

    if (result['success']) {
      _bookmarkedArticles.addAll(result['articles']);
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
  }

  // Fetch expert's own articles
  Future<void> fetchMyArticles({int page = 1, bool refresh = false}) async {
    if (page == 1 || refresh) {
      _myArticles.clear();
      _myCurrentPage = 1;
    }

    _isLoading = true;
    notifyListeners();

    final result = await _articleService.getMyArticles(page: page);
    _isLoading = false;

    if (result['success']) {
      _myArticles.addAll(result['articles']);
      _myCurrentPage = page;
      _myLastPage = result['lastPage'];
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
  }

  // Toggle bookmark
  Future<bool> toggleBookmark(Article article) async {
    final originalState = article.isBookmarked;

    // Optimistic UI update
    article.isBookmarked = !originalState;
    if (article.isBookmarked) {
      if (!_bookmarkedArticles.any((a) => a.id == article.id)) {
        _bookmarkedArticles.add(article);
      }
    } else {
      _bookmarkedArticles.removeWhere((a) => a.id == article.id);
    }
    notifyListeners();

    final result = await _articleService.toggleBookmark(article.id);

    if (result['success']) {
      article.isBookmarked = result['bookmarked'];
      if (article.isBookmarked) {
        if (!_bookmarkedArticles.any((a) => a.id == article.id)) {
          _bookmarkedArticles.add(article);
        }
      } else {
        _bookmarkedArticles.removeWhere((a) => a.id == article.id);
      }
      notifyListeners();
      return true;
    } else {
      // Revert if error
      article.isBookmarked = originalState;
      if (originalState) {
        if (!_bookmarkedArticles.any((a) => a.id == article.id)) {
          _bookmarkedArticles.add(article);
        }
      } else {
        _bookmarkedArticles.removeWhere((a) => a.id == article.id);
      }
      notifyListeners();
      return false;
    }
  }

  // Upload one image to embed inside an article's body content
  Future<String?> uploadContentImage(String imagePath) async {
    final result = await _articleService.uploadContentImage(imagePath);
    if (result['success'] == true) {
      return result['path'] as String?;
    }
    return null;
  }

  // Create article
  Future<bool> createArticle({
    required int categoryId,
    required String title,
    required String content,
    String? coverImagePath,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _articleService.createArticle(
      categoryId: categoryId,
      title: title,
      content: content,
      coverImagePath: coverImagePath,
    );

    _isActionLoading = false;

    if (result['success']) {
      final newArticle = result['article'] as Article;
      _myArticles.insert(0, newArticle);
      _articles.insert(0, newArticle);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Update article
  Future<bool> updateArticle({
    required int id,
    required int categoryId,
    required String title,
    required String content,
    String? coverImagePath,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _articleService.updateArticle(
      id: id,
      categoryId: categoryId,
      title: title,
      content: content,
      coverImagePath: coverImagePath,
    );

    _isActionLoading = false;

    if (result['success']) {
      final updated = result['article'] as Article;

      // Update in local lists
      final myIdx = _myArticles.indexWhere((a) => a.id == id);
      if (myIdx != -1) _myArticles[myIdx] = updated;

      final artIdx = _articles.indexWhere((a) => a.id == id);
      if (artIdx != -1) _articles[artIdx] = updated;

      final bookIdx = _bookmarkedArticles.indexWhere((a) => a.id == id);
      if (bookIdx != -1) _bookmarkedArticles[bookIdx] = updated;

      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Delete article
  Future<bool> deleteArticle(int id) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _articleService.deleteArticle(id);
    _isActionLoading = false;

    if (result['success']) {
      _myArticles.removeWhere((a) => a.id == id);
      _articles.removeWhere((a) => a.id == id);
      _bookmarkedArticles.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}