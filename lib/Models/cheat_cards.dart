import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheatCard extends StatefulWidget {
  final String title;
  final String desc;
  final String? phoneNum;
  final List<String> buttons;
  final bool isFavorite;
  final Function(String) onFavoriteToggle;
  final bool useImages;
  final String Function(String)? imageMapper;
  final VoidCallback? onTap;

  const CheatCard({
    required this.title,
    required this.desc,
    this.phoneNum,
    required this.buttons,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.useImages = true,
    this.imageMapper,
    this.onTap,
    super.key,
  });

  @override
  State<CheatCard> createState() => _CheatCardState();
}

class _CheatCardState extends State<CheatCard> {
  final Map<String, bool> _copiedMap = {};

  void _copyCode(String code) async {
    Clipboard.setData(ClipboardData(text: code));

    setState(() {
      _copiedMap[code] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$code" to clipboard'),
        backgroundColor: const Color.fromRGBO(0, 169, 115, 1),
        duration: const Duration(seconds: 1),
      ),
    );

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _copiedMap[code] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: const Color.fromRGBO(42, 40, 40, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            width: 1,
            color: Color.fromRGBO(76, 72, 72, 1),
          ),
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
                          widget.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (widget.phoneNum != null &&
                            widget.phoneNum!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Phone code: ${widget.phoneNum}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          widget.desc,
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
                      widget.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      color: widget.isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () => widget.onFavoriteToggle(widget.title),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              widget.useImages && widget.imageMapper != null
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.buttons.map((code) {
                        final imgPath = widget.imageMapper!(code);
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
                      children: widget.buttons.map((code) {
                        final copied = _copiedMap[code] ?? false;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(31, 69, 50, 1),
                                border: Border.all(
                                  width: 1.8,
                                  color: const Color.fromRGBO(31, 164, 106, 1),
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
                            const SizedBox(width: 12),
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
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  copied ? Icons.check : Icons.copy,
                                  color: copied
                                      ? const Color.fromRGBO(0, 255, 144, 1)
                                      : Colors.white,
                                  size: 16,
                                ),
                                onPressed: () => _copyCode(code),
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
