import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/amiibo.dart';
import '../service/api.dart';
import 'detailscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Amiibo>> futureAmiibos;
  List<String> favorites = [];
  List<Amiibo> filteredAmiibos = [];
  TextEditingController searchController = TextEditingController();
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    futureAmiibos = ApiService.getAllAmiibo();
    loadFavorites();
  }

  // Load favorit dari local storage
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  // Tambah/hapus favorit
  Future<void> toggleFavorite(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favorites.contains(name)) {
        favorites.remove(name);
      } else {
        favorites.add(name);
      }
    });
    await prefs.setStringList('favorites', favorites);
  }

  // Filter berdasarkan type
  List<Amiibo> getFilteredByType(List<Amiibo> allAmiibos) {
    if (selectedFilter == 'all') {
      return allAmiibos;
    }
    return allAmiibos
        .where((amiibo) =>
            amiibo.type.toLowerCase() == selectedFilter.toLowerCase())
        .toList();
  }

  // Filter search berdasarkan nama
  void filterSearch(String query, List<Amiibo> allAmiibos) {
    setState(() {
      List<Amiibo> typeFiltered = getFilteredByType(allAmiibos);

      if (query.isEmpty) {
        filteredAmiibos = typeFiltered;
      } else {
        filteredAmiibos = typeFiltered
            .where((amiibo) =>
                amiibo.name.toLowerCase().contains(query.toLowerCase()) ||
                amiibo.gameSeries.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nintendo Amiibo'),
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
        future: futureAmiibos,
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
            List<Amiibo> amiibos = snapshot.data!;

            // Inisialisasi filtered list pada pertama kali
            if (filteredAmiibos.isEmpty) {
              filteredAmiibos = amiibos;
            }

            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    onChanged: (query) => filterSearch(query, amiibos),
                    decoration: InputDecoration(
                      hintText: 'Search by name or series',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                filterSearch('', amiibos);
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.tune),
                              onPressed: () => _showFilterBottomSheet(),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          value: 'all',
                          onSelected: () {
                            setState(() {
                              selectedFilter = 'all';
                              filterSearch(searchController.text, amiibos);
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Figure',
                          value: 'Figure',
                          onSelected: () {
                            setState(() {
                              selectedFilter = 'Figure';
                              filterSearch(searchController.text, amiibos);
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Card',
                          value: 'Card',
                          onSelected: () {
                            setState(() {
                              selectedFilter = 'Card';
                              filterSearch(searchController.text, amiibos);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Grid List
                Expanded(
                  child: filteredAmiibos.isEmpty
                      ? const Center(
                          child: Text('No amiibo found'),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: filteredAmiibos.length,
                          itemBuilder: (context, index) {
                            Amiibo amiibo = filteredAmiibos[index];
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
                                );
                              },
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Image
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              const BorderRadius.only(
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
                                                    Icons
                                                        .image_not_supported,
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
                                                        : Icons
                                                            .favorite_border,
                                                    color: isFav
                                                        ? Colors.red
                                                        : Colors.grey,
                                                  ),
                                                  onPressed: () =>
                                                      toggleFavorite(
                                                          amiibo.name),
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
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required VoidCallback onSelected,
  }) {
    bool isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter By Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('All'),
                onTap: () {
                  setState(() {
                    selectedFilter = 'all';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Figure'),
                onTap: () {
                  setState(() {
                    selectedFilter = 'Figure';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Card'),
                onTap: () {
                  setState(() {
                    selectedFilter = 'Card';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}