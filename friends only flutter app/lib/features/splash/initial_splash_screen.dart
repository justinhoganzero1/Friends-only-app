import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math' as math;

class InitialSplashScreen extends StatefulWidget {
  const InitialSplashScreen({super.key});

  @override
  State<InitialSplashScreen> createState() => _InitialSplashScreenState();
}

class _InitialSplashScreenState extends State<InitialSplashScreen> with TickerProviderStateMixin {
  late AnimationController _haloController;
  late AnimationController _lipSyncController;
  late AnimationController _eyebrowController;
  late AnimationController _headTiltController;
  late AnimationController _smileController;
  // ignore: unused_field
  late Animation<double> _haloAnimation;
  late Animation<double> _lipSyncAnimation;
  late Animation<double> _eyebrowAnimation;
  late Animation<double> _headTiltAnimation;
  late Animation<double> _smileAnimation;
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  Timer? _autoNavigateTimer;
  double _swipeProgress = 0.0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVoice();
    _playWelcomeSpeech();
    _scheduleAutoNavigation();
  }

  void _scheduleAutoNavigation() {
    _autoNavigateTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/chat');
      }
    });
  }

  void _triggerNavigation() {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;
    _autoNavigateTimer?.cancel();
    Navigator.pushReplacementNamed(context, '/chat');
  }

  @override
  void dispose() {
    _autoNavigateTimer?.cancel();
    _haloController.dispose();
    _lipSyncController.dispose();
    _eyebrowController.dispose();
    _headTiltController.dispose();
    _smileController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _initializeAnimations() {
    // Halo pulsing effect
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _haloAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeInOut),
    );

    // Lip sync animation
    _lipSyncController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _lipSyncAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lipSyncController, curve: Curves.easeInOut),
    );

    // Eyebrow raise animation
    _eyebrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _eyebrowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _eyebrowController, curve: Curves.easeInOut),
    );

    // Head tilt animation
    _headTiltController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _headTiltAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _headTiltController, curve: Curves.easeInOut),
    );

    // Smile animation
    _smileController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _smileAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _smileController, curve: Curves.easeInOut),
    );
  }

  void _initializeVoice() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.85);
    await _tts.setPitch(1.8); // Female pitch
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });

    _tts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  void _playWelcomeSpeech() async {
    // Delay before starting
    await Future.delayed(const Duration(milliseconds: 500));

    // Smile at the start
    await _smileController.forward();

    // Raise eyebrow
    await Future.delayed(const Duration(milliseconds: 300));
    _eyebrowController.forward();

    // Speak welcome message with lip sync
    await Future.delayed(const Duration(milliseconds: 200));
    final welcomeText = "Welcome, dear friend. I am Pegasus, your digital oracle and guide. "
        "Together, we will create a safe, trusted space for connection. Enter now to begin our journey.";

    await _tts.speak(welcomeText);

    // Animate lip sync during speech
    _animateLipSync();
  }

  void _animateLipSync() {
    if (!_isSpeaking) return;

    _lipSyncController.forward().then((_) {
      if (_isSpeaking) {
        _lipSyncController.reverse().then((_) {
          _animateLipSync();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full Screen Pegasus/Oracle Background
          Image.asset(
            'assets/images/pegasus.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.black);
            },
          ),
          
          // Gold Dust Particle Effect
          CustomPaint(
            painter: GoldDustPainter(0.5),
            child: Container(),
          ),

          // Head Tilt Animation Wrapper
          AnimatedBuilder(
            animation: _headTiltAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _headTiltAnimation.value,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Eyebrow Animation Overlay
                    AnimatedBuilder(
                      animation: _eyebrowAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: EyebrowPainter(
                            eyebrowRaise: _eyebrowAnimation.value,
                            screenSize: MediaQuery.of(context).size,
                          ),
                          child: Container(),
                        );
                      },
                    ),

                    // Lip Sync Animation Overlay
                    AnimatedBuilder(
                      animation: _lipSyncAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: LipSyncPainter(
                            lipSync: _lipSyncAnimation.value,
                            screenSize: MediaQuery.of(context).size,
                          ),
                          child: Container(),
                        );
                      },
                    ),

                    // Smile Animation Overlay
                    AnimatedBuilder(
                      animation: _smileAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: SmilePainter(
                            smile: _smileAnimation.value,
                            screenSize: MediaQuery.of(context).size,
                          ),
                          child: Container(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          // Subtle gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),

          // Content - Title, description, button
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'FRIENDS ONLY',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 16, color: Color.fromARGB(200, 184, 134, 11), offset: Offset(0, 3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          // Swipe-to-enter control with thicker handle for easier interaction
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final trackWidth = math.min(constraints.maxWidth - 32, 440.0).clamp(240.0, 440.0).toDouble();
                    const handleSize = 64.0;
                    final available = (trackWidth - handleSize).clamp(1.0, double.infinity).toDouble();
                    final handleOffset = (_swipeProgress * available).clamp(0.0, available).toDouble();

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (_) => _autoNavigateTimer?.cancel(),
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          final delta = details.delta.dx / available;
                          _swipeProgress = (_swipeProgress + delta).clamp(0.0, 1.0);
                        });
                      },
                      onHorizontalDragEnd: (_) {
                        if (_swipeProgress >= 0.85) {
                          _triggerNavigation();
                        } else {
                          setState(() => _swipeProgress = 0.0);
                        }
                      },
                      child: Container(
                        width: trackWidth,
                        height: 78,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(48),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.12),
                              Colors.white.withValues(alpha: 0.06),
                            ],
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.6),
                        ),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Positioned.fill(
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: math.max(_swipeProgress, 0.02),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(36),
                                    color: const Color(0xFFF3C969).withValues(alpha: 0.35),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Swipe to enter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Thicker bar for easier grip',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(handleOffset, 0),
                              child: Container(
                                width: handleSize,
                                height: 58,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFE29F), Color(0xFFFFC662)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 28),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }}

// Gold dust particle painter
class GoldDustPainter extends CustomPainter {
  final double animationValue;

  GoldDustPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent particles
    final paint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.6 * (1 - (animationValue - 0.5).abs() * 2))
      ..style = PaintingStyle.fill;

    // Draw gold dust particles
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1;
      
      // Animated vertical movement
      final animatedY = y + (size.height * animationValue);
      
      // Opacity based on position
      final opacity = (1 - (animatedY % size.height) / size.height) * 0.6;
      paint.color = Colors.amber.withValues(alpha: opacity);
      
      canvas.drawCircle(Offset(x, animatedY % size.height), radius, paint);
    }
  }

  @override
  bool shouldRepaint(GoldDustPainter oldDelegate) => true;
}

// Eyebrow animation painter
class EyebrowPainter extends CustomPainter {
  final double eyebrowRaise;
  final Size screenSize;

  EyebrowPainter({required this.eyebrowRaise, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.3 * eyebrowRaise)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Left eyebrow position (approximate)
    final leftEyebrowY = screenSize.height * 0.22 - (eyebrowRaise * 10);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(screenSize.width * 0.35, leftEyebrowY),
        width: 30,
        height: 20,
      ),
      0,
      math.pi,
      false,
      paint,
    );

    // Right eyebrow position
    final rightEyebrowY = screenSize.height * 0.22 - (eyebrowRaise * 10);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(screenSize.width * 0.65, rightEyebrowY),
        width: 30,
        height: 20,
      ),
      0,
      math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(EyebrowPainter oldDelegate) => oldDelegate.eyebrowRaise != eyebrowRaise;
}

// Lip sync animation painter
class LipSyncPainter extends CustomPainter {
  final double lipSync;
  final Size screenSize;

  LipSyncPainter({required this.lipSync, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pinkAccent.withValues(alpha: 0.4 * lipSync)
      ..style = PaintingStyle.fill;

    // Lips position (approximate center-bottom of face)
    final lipY = screenSize.height * 0.38;
    final lipX = screenSize.width * 0.5;
    
    // Animated mouth opening
    final mouthOpen = lipSync * 8;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(lipX, lipY),
        width: 20,
        height: 8 + mouthOpen,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(LipSyncPainter oldDelegate) => oldDelegate.lipSync != lipSync;
}

// Smile animation painter
class SmilePainter extends CustomPainter {
  final double smile;
  final Size screenSize;

  SmilePainter({required this.smile, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amberAccent.withValues(alpha: 0.3 * smile)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Smile curve at mouth position
    final smileY = screenSize.height * 0.38;
    final smileX = screenSize.width * 0.5;
    
    if (smile > 0) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(smileX, smileY + 5),
          width: 40,
          height: 25,
        ),
        0,
        math.pi,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SmilePainter oldDelegate) => oldDelegate.smile != smile;
}