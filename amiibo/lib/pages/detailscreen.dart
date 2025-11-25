import 'package:flutter/material.dart';
import '../models/amiibo.dart';

class DetailScreen extends StatefulWidget {
  final Amiibo amiibo;
  final bool isFavorite;
  final Function(String) onFavoriteToggle;

  const DetailScreen({
    super.key,
    required this.amiibo,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.isFavorite; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Amiibo Details',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.amiibo.image.isNotEmpty
                    ? Image.network(
                        widget.amiibo.image,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported, size: 100),
              ),
              const SizedBox(height: 20),
              Text(
                widget.amiibo.gameSeries,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                widget.amiibo.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Character Info Section
              _buildSectionTitle('Character Info'),
              const SizedBox(height: 12),
              _buildInfoTile('Character', widget.amiibo.character ?? 'N/A'),
              _buildInfoTile('Head', widget.amiibo.head ?? 'N/A'),
              _buildInfoTile('Tail', widget.amiibo.tail ?? 'N/A'),
              _buildInfoTile("Type", widget.amiibo.type ?? "N/A"),
              const SizedBox(height: 24),

              _buildSectionTitle('Regional Release Dates'),
              const SizedBox(height: 12),
              _buildReleaseDate('🇦🇺 Australia', widget.amiibo.releaseau ?? 'N/A'),
              _buildReleaseDate('🇪🇺 Europe', widget.amiibo.releaseeu ?? 'N/A'),
              _buildReleaseDate('🇯🇵 Japan', widget.amiibo.releasejp ?? 'N/A'),
              _buildReleaseDate('🇺🇸 North America', widget.amiibo.releasena ?? 'N/A'),
              const SizedBox(height: 20),

                // Definisikan fungsi yang akan dijalankan saat tombol diklik
        

        InkWell(
          // Properti utama untuk membuat widget ini dapat diklik
          onTap: _handleFavoriteToggle,
          
          // Properti opsional untuk memberi feedback visual (efek riak)
          borderRadius: BorderRadius.circular(8),
          
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            // Pindahkan Decoration ke Container untuk mempertahankan bentuk dan warna
            decoration: BoxDecoration(
              color: isFav ? Colors.red[100] : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            
            // Perbaikan: Gunakan 'child' dan 'Row' untuk menampung banyak widget
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  isFav ? 'Added to Favorites' : 'Not in Favorites',
                  style: TextStyle(
                    color: isFav ? Colors.red : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleFavoriteToggle() {
    setState(() {
      isFav = !isFav;
      
  print('Tombol Favorit diklik! Nilai isFav saat ini: $isFav');
      widget.onFavoriteToggle(widget.amiibo.tail);
    });
  }

  
  Widget _buildReleaseDate(String region, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              region,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}