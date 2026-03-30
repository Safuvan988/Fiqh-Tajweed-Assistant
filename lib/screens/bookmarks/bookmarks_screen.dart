import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/models/bookmark_model.dart';
import 'package:quranfiqh/services/firestore_service.dart';
import 'package:intl/intl.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late Future<List<BookmarkModel>> _bookmarksFuture;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    if (user != null) {
      _bookmarksFuture = FirestoreService.getBookmarks(user!.uid);
    } else {
      _bookmarksFuture = Future.value([]);
    }
  }

  void _deleteBookmark(String id) async {
    if (user != null) {
      await FirestoreService.deleteBookmark(user!.uid, id);
      setState(() {
        _loadBookmarks();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bookmark removed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Saved Answers'),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        elevation: 0,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view bookmarks'))
          : FutureBuilder<List<BookmarkModel>>(
              future: _bookmarksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading bookmarks'));
                }
                final bookmarks = snapshot.data ?? [];
                if (bookmarks.isEmpty) {
                  return const Center(child: Text('No saved answers yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final bm = bookmarks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      surfaceTintColor: Colors.transparent,
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    bm.question,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _deleteBookmark(bm.id),
                                ),
                              ],
                            ),
                            const Divider(),
                            Text(
                              bm.answer,
                              style: AppTextStyles.englishBody(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                DateFormat(
                                  'MMM d, y h:mm a',
                                ).format(bm.createdAt),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
