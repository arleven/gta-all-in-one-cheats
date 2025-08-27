import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheatCard extends StatelessWidget {
  final String title;
  final String desc;
  final List<String> buttons;
  final bool isFavorite;
  final Function(String) onFavoriteToggle;
  final bool useImages;
  final String Function(String)? imageMapper;
  final VoidCallback? onTap;

  const CheatCard({
    required this.title,
    required this.desc,
    required this.buttons,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.useImages = true,
    this.imageMapper,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      color: Colors.greenAccent,
                    ),
                    onPressed: () => onFavoriteToggle(title),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              useImages && imageMapper != null
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: buttons.map((code) {
                        final imgPath = imageMapper!(code);
                        return Image.asset(
                          imgPath,
                          height: 40,
                          width: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey,
                              alignment: Alignment.center,
                              child: Text(
                                code,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: buttons.map((code) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[200]?.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.green.shade700,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                code,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.copy,
                                color: Colors.greenAccent,
                                size: 20,
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Copied "$code" to clipboard',
                                    ),
                                    backgroundColor: Colors.green[800],
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
