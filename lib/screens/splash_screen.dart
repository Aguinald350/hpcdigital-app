// lib/screens/splash_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'LoginScreen.dart';
import '../theme/app_theme.dart';

class splash_screen extends StatefulWidget {
  final void Function(AppTheme mode)? onThemeChanged;
  final void Function(AppTheme t)? themeSetter;

  const splash_screen({
    super.key,
    this.onThemeChanged,
    this.themeSetter,
  });

  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> with TickerProviderStateMixin {
  /// Splash de 5 segundos totais:
  /// 2s efeito + 1s crossfade + 2s conteúdo = 5s
  static const Duration kInitialEffectHold = Duration(seconds: 2);
  static const Duration kCrossFade = Duration(seconds: 1);
  static const Duration kContentVisible = Duration(seconds: 2);
  static final Duration kSplashTotal = kInitialEffectHold + kCrossFade + kContentVisible;

  late final AnimationController _effectOpacityCtrl;
  late final AnimationController _contentOpacityCtrl;
  late final Animation<double> _effectOpacityAnim;
  late final Animation<double> _contentOpacityAnim;

  late final Ticker _ticker;
  DateTime? _lastTickTime;

  final ValueNotifier<int> _repaintNotifier = ValueNotifier<int>(0);

  late final _HackerRain _rain;

  Timer? _navTimer;
  Timer? _startCrossFadeTimer;

  @override
  void initState() {
    super.initState();

    _effectOpacityCtrl = AnimationController(vsync: this, duration: kCrossFade);
    _effectOpacityAnim = CurvedAnimation(parent: _effectOpacityCtrl, curve: Curves.easeOut);

    _contentOpacityCtrl = AnimationController(vsync: this, duration: kCrossFade);
    _contentOpacityAnim = CurvedAnimation(parent: _contentOpacityCtrl, curve: Curves.easeIn);

    _rain = _HackerRain(seed: DateTime.now().millisecondsSinceEpoch);

    _ticker = createTicker((elapsed) {
      final now = DateTime.now();
      final last = _lastTickTime ?? now;
      final dt = now.difference(last).inMilliseconds / 1000.0;
      _lastTickTime = now;

      _rain.tick(dt);
      _repaintNotifier.value++;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _rain.ensureInitialized(size);
      _lastTickTime = DateTime.now();
      _ticker.start();
    });

    _startCrossFadeTimer = Timer(kInitialEffectHold, () {
      if (!mounted) return;
      _contentOpacityCtrl.forward();
      _effectOpacityCtrl.forward();
    });

    _navTimer = Timer(kSplashTotal, () {
      if (!mounted) return;
      try {
        _ticker.stop();
      } catch (_) {}
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Loginscreen()));
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _startCrossFadeTimer?.cancel();
    try {
      _ticker.dispose();
    } catch (_) {}
    _effectOpacityCtrl.dispose();
    _contentOpacityCtrl.dispose();
    _repaintNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    _rain.ensureInitialized(MediaQuery.of(context).size);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _effectOpacityAnim,
            builder: (_, __) {
              final effectAlpha = (1.0 - _effectOpacityAnim.value).clamp(0.0, 1.0);
              return Opacity(
                opacity: effectAlpha,
                child: CustomPaint(
                  painter: _HackerRainPainter(_rain, repaint: _repaintNotifier),
                  size: Size.infinite,
                ),
              );
            },
          ),

          Center(
            child: FadeTransition(
              opacity: _contentOpacityAnim,
              child: _buildContent(primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Color primary) {
    const title = 'HOSANA PROJECTO CRISTÃO';
    const slogan = 'Adorando juntos em qualquer lugar, unidos pela fé, conectados em Cristo';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: Image.asset('images/icon.png', fit: BoxFit.contain),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Text(
            slogan,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: primary.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// =======================
/// Hacker Matrix Orange Effect
/// =======================

class _HackerRain {
  _HackerRain({int? seed}) : _rand = Random(seed);

  final Random _rand;
  late Size screen;
  bool _initialized = false;

  static const String slogan = 'AGUINALDODEJESUS';
  static const String fallback = 'MARTINSMADEIRA';
  late List<String> _chars;

  final List<_HackerColumn> cols = [];
  late List<Color> palette;

  static const double _colWidth = 20.0;
  static const int _minCols = 8;

  void ensureInitialized(Size s) {
    if (_initialized && screen == s) return;

    screen = s;
    final base = slogan.isEmpty ? fallback : slogan;
    _chars = base.split('');

    const Color baseColor = Color(0xFFEC8A00);
    palette = [
      baseColor.withOpacity(1.0),
      baseColor.withOpacity(0.92),
      baseColor.withOpacity(0.78),
      baseColor.withOpacity(0.62),
    ];

    _spawnColumns();
    _initialized = true;
  }

  void _spawnColumns() {
    cols.clear();
    final nCols = max(_minCols, (screen.width / _colWidth).floor());
    for (int i = 0; i < nCols; i++) {
      final x = (i + 0.5) * (screen.width / nCols);
      cols.add(_HackerColumn(
        x: x,
        screenHeight: screen.height,
        rand: _rand,
        chars: _chars,
        palette: palette,
      ));
    }
  }

  void tick(double dt) {
    if (!_initialized) return;

    for (final c in cols) {
      c.tick(dt);
    }
  }
}

class _HackerColumn {
  _HackerColumn({
    required this.x,
    required this.screenHeight,
    required this.rand,
    required this.chars,
    required this.palette,
  }) {
    _reset();
  }

  final double x;
  final double screenHeight;
  final Random rand;
  final List<String> chars;
  final List<Color> palette;

  double headY = -200.0;
  double speed = 60.0;
  int length = 8;
  double charHeight = 18.0;
  double opacity = 1.0;
  int ticksSinceReset = 0;
  bool active = true;

  String getChar(int idx) {
    final i = (idx + ticksSinceReset) % chars.length;
    return chars[i];
  }

  void _reset() {
    headY = -rand.nextDouble() * 400.0 - 40.0;
    speed = 40 + rand.nextDouble() * 180;
    length = 6 + rand.nextInt(12);
    charHeight = 12 + rand.nextDouble() * 14;
    opacity = 0.65 + rand.nextDouble() * 0.4;
    ticksSinceReset = rand.nextInt(1000);
    active = true;
  }

  void tick(double dt) {
    if (!active) return;

    headY += speed * dt;
    ticksSinceReset++;

    if (rand.nextDouble() < 0.0012) {
      active = false;
      Future.delayed(Duration(milliseconds: 120 + rand.nextInt(700)), () {
        active = true;
      });
    }

    if (headY - length * charHeight > screenHeight + 60) {
      _reset();
    }
  }
}

class _HackerRainPainter extends CustomPainter {
  final _HackerRain rain;

  _HackerRainPainter(this.rain, {Listenable? repaint}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    if (!rain._initialized) return;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final col in rain.cols) {
      final headY = col.headY;
      final len = col.length;
      final chH = col.charHeight;

      for (int i = 0; i < len; i++) {
        final dy = headY - i * chH;
        if (dy < -80 || dy > size.height + 80) continue;

        final ch = col.getChar(i);
        final baseColor = col.palette[i % col.palette.length];
        final alpha = col.opacity * (1 - i / len * 0.9);

        textPainter.text = TextSpan(
          text: ch,
          style: TextStyle(
            color: baseColor.withOpacity(alpha.clamp(0.05, 1.0)),
            fontSize: chH,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        );

        textPainter.layout();
        final dx = col.x - textPainter.width / 2;
        textPainter.paint(canvas, Offset(dx, dy));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
