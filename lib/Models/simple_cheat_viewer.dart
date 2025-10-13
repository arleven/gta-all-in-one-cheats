import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SimpleCheatViewer extends StatelessWidget {
  final String? videourl;
  final String? desc;
  final String? code;

  const SimpleCheatViewer({this.videourl, this.desc, this.code, super.key});

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],

          if (code != null && code!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              code!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
