import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SimpleCheatViewer extends StatelessWidget {
  final String? videourl;
  final String? desc;
  final String? code;
  final String? title;

  const SimpleCheatViewer({
    this.videourl,
    this.desc,
    this.code,
    this.title,
    super.key,
  });

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
    YoutubePlayerController? youtubeController;

    if (videourl != null && videourl!.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(
        'https://www.youtube.com/watch?v=bsKuFbSPXfg&t=37s',
      );
      if (videoId != null) {
        youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: false,
          ),
        );
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDragHandle(),

          if (title != null && title!.isNotEmpty) ...[
            Center(
              child: Text(
                title!,
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

          if (youtubeController != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: screenWidth * 0.9,
                height: screenWidth * 0.5,
                color: Colors.black,
                child: YoutubePlayer(
                  controller: youtubeController,
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

          if (desc != null && desc!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              desc!,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],

          if (code != null && code!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Text(
                code!,
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
