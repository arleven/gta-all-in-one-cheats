import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SimpleCheatViewer extends StatefulWidget {
  final String? videourl;
  final String? desc;
  final String? code;
  final String title;

  const SimpleCheatViewer({
    this.videourl,
    this.desc,
    this.code,
    required this.title,
    super.key,
  });

  @override
  State<SimpleCheatViewer> createState() => _SimpleCheatViewerState();
}

class _SimpleCheatViewerState extends State<SimpleCheatViewer> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();

    if (widget.videourl != null && widget.videourl!.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(
        'https://www.youtube.com/watch?v=bsKuFbSPXfg&t=37s',
      );
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            loop: false,
            enableCaption: false,
          ),
        );

        _youtubeController!.addListener(() {
          if (_youtubeController!.value.playerState == PlayerState.ended) {
            _youtubeController!.seekTo(Duration.zero);
            _youtubeController!.play();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Widget buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 12),
        height: 4,
        width: 40,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(76, 72, 72, 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDragHandle(),

          if (widget.title.isNotEmpty) ...[
            Center(
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_youtubeController != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: screenWidth * 0.9,
                height: screenWidth * 0.5,
                color: Colors.black,
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.greenAccent,
                  bottomActions: [
                    const SizedBox(width: 14.0),
                    CurrentPosition(),
                    const SizedBox(width: 8.0),
                    ProgressBar(
                      isExpanded: true,
                      colors: const ProgressBarColors(
                        playedColor: Colors.greenAccent,
                        handleColor: Colors.white,
                      ),
                    ),
                    const PlaybackSpeedButton(),
                  ],
                ),
              ),
            ),

          if (widget.desc != null && widget.desc!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              widget.desc!,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],

          if (widget.code != null && widget.code!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Text(
                widget.code!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
