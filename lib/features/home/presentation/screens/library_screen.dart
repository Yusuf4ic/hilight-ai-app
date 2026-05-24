import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  static const _books = [
    _Book('Steal Like An Artist', 'Austin Kleon', '12 highlights', 0xFFF5A623),
    _Book('Deep Work', 'Cal Newport', '8 highlights', 0xFF7F77DD),
    _Book('Atomic Habits', 'James Clear', '21 highlights', 0xFF5DCAA5),
    _Book('The War of Art', 'Steven Pressfield', '5 highlights', 0xFFE07070),
    _Book('Show Your Work', 'Austin Kleon', '9 highlights', 0xFF5B9BD5),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(),
          _buildSearchBar(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _books.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _BookTile(book: _books[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        S.library,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.4,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, size: 18, color: AppColors.textHint),
          const SizedBox(width: 8),
          Text(
            S.searchBooks,
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _Book {
  final String title;
  final String author;
  final String highlights;
  final int color;

  const _Book(this.title, this.author, this.highlights, this.color);
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book});

  final _Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Book cover placeholder
          Container(
            width: 48,
            height: 64,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Color(book.color).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border(
                left: BorderSide(color: Color(book.color), width: 3),
              ),
            ),
            child: Icon(
              Icons.menu_book,
              color: Color(book.color),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.bookmark,
                      size: 13,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      book.highlights,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }
}
