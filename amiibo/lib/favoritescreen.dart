import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/amiibo.dart';
import '../service/api.dart';
import 'detailscreen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  // Load favorit dari local storage
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  // Toggle favorite
  Future<void> toggleFavorite(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favorites.contains(name)) {
        favorites.remove(name);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name removed from favorites'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        favorites.add(name);
      }
    });
    await prefs.setStringList('favorites', favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Amiibo>>(
        future: ApiService.getAllAmiibo(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Data berhasil
          if (snapshot.hasData) {
            List<Amiibo> allAmiibos = snapshot.data!;

            // Filter favorit
            List<Amiibo> favoritedAmiibos = allAmiibos
                .where((amiibo) => favorites.contains(amiibo.name))
                .toList();

            return favoritedAmiibos.isEmpty
                ? const Center(
                    child: Text('No favorites yet'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: favoritedAmiibos.length,
                    itemBuilder: (context, index) {
                      Amiibo amiibo = favoritedAmiibos[index];
                      bool isFav = favorites.contains(amiibo.name);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                amiibo: amiibo,
                                isFavorite: isFav,
                                onFavoriteToggle: toggleFavorite,
                              ),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                        child: Dismissible(
                          key: Key(amiibo.name),
                          onDismissed: (direction) {
                            toggleFavorite(amiibo.name);
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        amiibo.image.isNotEmpty
                                            ? Image.network(
                                                amiibo.image,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              )
                                            : const Icon(
                                                Icons.image_not_supported,
                                              ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                isFav
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isFav
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                              onPressed: () =>
                                                  toggleFavorite(amiibo.name),
                                              iconSize: 20,
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(
                                                minWidth: 32,
                                                minHeight: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Info
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        amiibo.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        amiibo.gameSeries,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
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
                  );
          }

          return const Center(child: Text('No data'));
        },
      ),
    );
  }
}