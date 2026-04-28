import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants.dart';

/// Krok 4 – Fotodokumentace.
/// Zobrazuje seznam kategorií z [photoCategories]; ke každé lze přidat fotky
/// z galerie nebo sériovým focením. Miniatury lze individuálně mazat.
class StepPhoto extends StatelessWidget {
  final bool isDark;
  final Map<String, List<XFile>> categoryImages;
  final void Function(String categoryKey) onPickFromGallery;
  final void Function(String categoryKey) onTakePhotoSeries;
  final void Function(String categoryKey, int photoIndex) onRemovePhoto;

  const StepPhoto({
    super.key,
    required this.isDark,
    required this.categoryImages,
    required this.onPickFromGallery,
    required this.onTakePhotoSeries,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fotodokumentace',
              style:
                  TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text(
              'Vyfoťte sérii fotek, nebo vyberte hromadně z galerie.',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: photoCategories.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final key =
                    photoCategories.keys.elementAt(index);
                final category = photoCategories[key]!;
                final label = category['label'] as String;
                final icon = category['icon'] as IconData;
                final takenPhotos = categoryImages[key] ?? [];

                return Card(
                  color: isDark
                      ? const Color(0xFF1A1A1A)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: takenPhotos.isNotEmpty
                              ? Colors.green.withValues(alpha: 0.5)
                              : Colors.grey.withValues(alpha: 0.2),
                          width: takenPhotos.isNotEmpty ? 2 : 1)),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(icon,
                                color: Colors.blue, size: 30),
                            const SizedBox(width: 15),
                            Expanded(
                                child: Text(label,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold))),
                            IconButton(
                                onPressed: () =>
                                    onPickFromGallery(key),
                                icon: const Icon(
                                    Icons.photo_library_rounded,
                                    color: Colors.blueGrey),
                                tooltip: 'Přidat z galerie'),
                            IconButton(
                                onPressed: () =>
                                    onTakePhotoSeries(key),
                                icon: const Icon(
                                    Icons.add_a_photo_rounded,
                                    color: Colors.blue),
                                tooltip: 'Sériové focení'),
                          ],
                        ),
                        if (takenPhotos.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: takenPhotos.length,
                              itemBuilder: (context, photoIndex) {
                                final photo =
                                    takenPhotos[photoIndex];
                                return Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          right: 10),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  10),
                                          child: kIsWeb
                                              ? Image.network(
                                                  photo.path,
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover)
                                              : Image.file(
                                                  File(photo.path),
                                                  width: 80,
                                                  height: 80,
                                                  fit:
                                                      BoxFit.cover)),
                                    ),
                                    Positioned(
                                        top: 4,
                                        right: 14,
                                        child: GestureDetector(
                                            onTap: () => onRemovePhoto(
                                                key, photoIndex),
                                            child:
                                                const CircleAvatar(
                                                    radius: 10,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Icon(
                                                        Icons.close,
                                                        size: 14,
                                                        color: Colors
                                                            .red)))),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
