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
        color: Color.fromRGBO(42, 40, 40, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(width: 1, color: Color.fromRGBO(76, 72, 72, 1)),
        ),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(167, 167, 167, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      color: isFavorite
                          ? Colors.red
                          : Color.fromRGBO(255, 255, 255, 1),
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
                                color: Color.fromRGBO(31, 69, 50, 1),
                                border: Border.all(
                                  width: 1.8,
                                  color: Color.fromRGBO(31, 164, 106, 1),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                code,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Container(
                              width: 33,
                              height: 33,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(48, 50, 57, 1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color.fromRGBO(76, 82, 79, 1),
                                  width: 1.8,
                                ),
                              ),
                              child: IconButton(
                                padding: const EdgeInsets.all(0),
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                  size: 16,
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
