import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:story_app/generated/l10n.dart';
import 'package:story_app/providers/auth_provider.dart';
import 'package:story_app/providers/story_provider.dart';
import 'package:story_app/services/preferences_service.dart';

class StoryListScreen extends StatefulWidget {
  final String isPaid;

  const StoryListScreen({super.key, required this.isPaid});

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    debugPrint("BACK BUTTON!"); // Do some stuff.
    return true;
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    _fetchStories();
  }

  Future<void> _fetchStories() async {
    final tokenIn = await PreferencesService.getToken();

    final storyProvider = Provider.of<StoryProvider>(context, listen: false);

    await storyProvider.fetchStories(refresh: true, token: tokenIn.toString());

    if (!mounted) return;

    await storyProvider.requestPermissions();
    if (storyProvider.hasAllPermissions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All permissions granted!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions denied!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).stories + ' ' + widget.isPaid),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final tokenIn = await PreferencesService.getToken();
          await storyProvider.fetchStories(
              refresh: true, token: tokenIn.toString());
        },
        child: storyProvider.isLoading && storyProvider.stories.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: storyProvider.stories.length +
                    (storyProvider.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == storyProvider.stories.length) {
                    _loadMoreStories();
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final story = storyProvider.stories[index];
                  return GestureDetector(
                    onTap: () {
                      context.go('/storyDetail/${story.id}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0),
                              ),
                              child: FadeInImage.assetNetwork(
                                image: story.photoUrl,
                                placeholder: 'assets/default_image.jpg',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
                                  return Image.asset(
                                      'assets/default_image.jpg');
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${story.id}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    story.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Visibility(
                                    visible: false,
                                    child: Text(
                                      story.lat.toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ),
                                  const SizedBox(height: 8),
                                  // CreatedAt
                                  Text(
                                    'Created on: ${story.createdAt.toLocal().toString()}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/addStory');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _loadMoreStories() async {
    final tokenIn = await PreferencesService.getToken();
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    await storyProvider.fetchStories(
        refresh: false, token: tokenIn.toString()); // Hanya ambil data baru
  }
}
