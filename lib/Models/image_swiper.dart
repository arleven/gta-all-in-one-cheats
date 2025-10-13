import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SlidingImageViewer extends StatefulWidget {
  final List<String> imagePaths;
  final List<String> codeTexts;

  const SlidingImageViewer({
    required this.imagePaths,
    required this.codeTexts,

    super.key,
  });

  @override
  State<SlidingImageViewer> createState() => _SlidingImageViewerState();
}

class _SlidingImageViewerState extends State<SlidingImageViewer> {
  late PageController _controller;
  Timer? _autoSlideTimer;
  int _currentIndex = 0;
  int _currentSpeedMultiplier = 1;
  final FlutterTts _flutterTts = FlutterTts();
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.5);

    const videoUrl = 'https://www.youtube.com/watch?v=bsKuFbSPXfg&t=34s';
    final videoId = YoutubePlayer.convertUrlToId(videoUrl)!;

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false,
      ),
    );

    _loadSavedSpeed().then((_) {
      _setupTts().then((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _speakCode(widget.codeTexts[0]);
          _startAutoSlider();
        });
      });
    });
  }

  Future<void> _loadSavedSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSpeed = prefs.getInt('selected_speed');
    if (savedSpeed != null) {
      _currentSpeedMultiplier = savedSpeed;
    }
    setState(() {});
  }

  Future<void> _saveSpeed(int speed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_speed', speed);
  }

  Future<void> _setupTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _speakCode(String code) async {
    await _flutterTts.stop();

    final words = code.split(' ').map((word) {
      if (word.length == 1) {
        return word.toLowerCase();
      }
      return word;
    }).toList();

    final spokenText = words.join(' ');
    await _flutterTts.speak(spokenText);
  }

  void _startAutoSlider() {
    _autoSlideTimer?.cancel();
    double secondsPerSlide;

    switch (_currentSpeedMultiplier) {
      case 1:
        secondsPerSlide = 2.0;
        break;
      case 2:
        secondsPerSlide = 1.0;
        break;
      case 3:
        secondsPerSlide = 0.5;
        break;
      default:
        secondsPerSlide = 1.5;
    }

    _autoSlideTimer = Timer.periodic(
      Duration(milliseconds: (secondsPerSlide * 1000).toInt()),
      (timer) {
        if (!mounted) return;

        if (_currentIndex < widget.imagePaths.length - 1) {
          _currentIndex++;
          _controller.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          _speakCode(widget.codeTexts[_currentIndex]);
        } else {
          _autoSlideTimer?.cancel();
        }
      },
    );
  }

  void _restartSlider() {
    _currentIndex = 0;
    _controller.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _speakCode(widget.codeTexts[0]);
    Future.delayed(const Duration(milliseconds: 600), _startAutoSlider);
  }

  void _changeSpeed(int speedMultiplier) {
    setState(() {
      _currentSpeedMultiplier = speedMultiplier;
    });
    _saveSpeed(speedMultiplier);
    _startAutoSlider();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _controller.dispose();
    _flutterTts.stop();

    super.dispose();
  }

  Widget _buildSpeedButton(int speedMultiplier) {
    final isSelected = _currentSpeedMultiplier == speedMultiplier;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.grey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: () => _changeSpeed(speedMultiplier),
      child: Text(
        '${speedMultiplier}x',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: screenWidth * 0.9,
          height: screenWidth * 0.5,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: YoutubePlayer(
            controller: _youtubeController,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSheetMaxHeight = MediaQuery.of(context).size.height * 0.8;

    return SizedBox(
      height: bottomSheetMaxHeight,
      child: Column(
        children: [
          _buildVideoPlayer(),

          const SizedBox(height: 12),

          Expanded(
            flex: 2,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.imagePaths.length,
              onPageChanged: (index) => _currentIndex = index,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_controller.position.haveDimensions) {
                      final currentPage =
                          _controller.page ??
                          _controller.initialPage.toDouble();
                      value = currentPage - index;
                      value = (1 - (value.abs() * 0.3))
                          .clamp(0.7, 1.0)
                          .toDouble();
                    }

                    final isFocused = (_controller.page?.round() ?? 0) == index;

                    return Transform.scale(
                      scale: value * 0.99,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                widget.imagePaths[index],
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            if (!isFocused)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 4,
                                    sigmaY: 4,
                                  ),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Speed buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSpeedButton(1),
              const SizedBox(width: 12),
              _buildSpeedButton(2),
              const SizedBox(width: 12),
              _buildSpeedButton(3),
            ],
          ),

          const SizedBox(height: 12),

          // Restart button
          IconButton(
            icon: const Icon(
              Icons.restart_alt,
              size: 30,
              color: Colors.greenAccent,
            ),
            onPressed: _restartSlider,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
