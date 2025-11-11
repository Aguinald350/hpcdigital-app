// // lib/screens/splash_screen.dart
// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'LoginScreen.dart';
// import '../theme/app_theme.dart';
//
// class splash_screen extends StatefulWidget {
//   /// Callback antigo (opcional)
//   final void Function(AppTheme mode)? onThemeChanged;
//
//   /// NOVO callback para combinar com o seu main.dart
//   final void Function(AppTheme t)? themeSetter;
//
//   const splash_screen({
//     super.key,
//     this.onThemeChanged,
//     this.themeSetter, // <- agora disponível
//   });
//
//   @override
//   State<splash_screen> createState() => _splash_screenState();
// }
//
// class _splash_screenState extends State<splash_screen>
//     with TickerProviderStateMixin {
//   static const Duration kSplashTotal = Duration(seconds: 4);
//
//   late final AnimationController _contentCtrl;
//   late final Animation<double> _contentOpacity;
//   late final Animation<double> _contentScale;
//
//   late final AnimationController _rainCtrl;
//   late final _NotesRain _rain;
//
//   Timer? _navTimer;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _contentCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 650),
//     )..forward();
//
//     _contentOpacity = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut),
//     );
//     _contentScale = Tween<double>(begin: 0.985, end: 1.0).animate(
//       CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
//     );
//
//     _rainCtrl = AnimationController.unbounded(vsync: this)
//       ..addListener(() => _rain.tick())
//       ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 16));
//
//     _rain = _NotesRain(seed: 42);
//
//     _navTimer = Timer(kSplashTotal, () {
//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const Loginscreen()),
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     _navTimer?.cancel();
//     _rainCtrl.dispose();
//     _contentCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final primary = Theme.of(context).colorScheme.primary;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           _rain.ensureInitialized(constraints.biggest, primary);
//
//           return Stack(
//             fit: StackFit.expand,
//             children: [
//               AnimatedBuilder(
//                 animation: _contentCtrl,
//                 builder: (_, __) => Opacity(
//                   opacity: _contentOpacity.value,
//                   child: Transform.scale(
//                     scale: _contentScale.value,
//                     child: _buildContent(primary),
//                   ),
//                 ),
//               ),
//               AnimatedBuilder(
//                 animation: _rainCtrl,
//                 builder: (_, __) => CustomPaint(
//                   painter: _NotesRainPainter(_rain),
//                   size: Size.infinite,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildContent(Color primary) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const SizedBox(height: 20),
//           Image.asset(
//             'images/splashscreen.png',
//             width: 250,
//             height: 250,
//             fit: BoxFit.contain,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'HPC DIGITAL',
//             style: TextStyle(
//               fontSize: 28,
//               color: primary,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1.5,
//             ),
//           ),
//           const SizedBox(height: 14),
//           Text(
//             'Adorando juntos em qualquer lugar,\nunindo gerações em louvor.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 16,
//               color: primary,
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// ======== Sistema de partículas (notas musicais) ========
//
// class _NotesRain {
//   _NotesRain({int? seed})
//       : _rand = Random(seed),
//         lastTick = DateTime.now();
//
//   final Random _rand;
//
//   static const List<String> glyphs = ['♪', '♫', '♩', '♬', '♭', '♯', '𝄞', '🎼'];
//
//   late List<Color> palette;
//   final List<_NoteParticle> ps = [];
//
//   late Size screen;
//   bool _initialized = false;
//
//   DateTime lastTick;
//
//   void ensureInitialized(Size s, Color themePrimary) {
//     if (_initialized) return;
//     screen = s;
//
//     final p = HSLColor.fromColor(themePrimary);
//     palette = [
//       p.withLightness((p.lightness + 0.15).clamp(0.0, 1.0)).toColor(),
//       p.withLightness((p.lightness + 0.05).clamp(0.0, 1.0)).toColor(),
//       p.toColor(),
//       p.withLightness((p.lightness - 0.08).clamp(0.0, 1.0)).toColor(),
//       p.withSaturation((p.saturation * 0.85).clamp(0.0, 1.0)).toColor(),
//       p.withSaturation((p.saturation * 1.10).clamp(0.0, 1.0)).toColor(),
//     ];
//
//     _spawnMany();
//     _initialized = true;
//   }
//
//   void _spawnMany() {
//     final baseCount =
//     (screen.width * screen.height / 16000).clamp(28, 80).toInt();
//     ps.clear();
//     for (int i = 0; i < baseCount; i++) {
//       ps.add(_randomParticle(startRandomY: true));
//     }
//   }
//
//   _NoteParticle _randomParticle({bool startRandomY = false}) {
//     final x = _rand.nextDouble() * screen.width;
//     final y = startRandomY
//         ? _rand.nextDouble() * screen.height
//         : -40.0 - _rand.nextDouble() * 120.0;
//
//     final speed = 90 + _rand.nextDouble() * 160;
//     final driftAmp = 10 + _rand.nextDouble() * 30;
//     final driftFreq = 0.6 + _rand.nextDouble() * 1.4;
//     final phase = _rand.nextDouble() * pi * 2;
//
//     final rotSpeed =
//         (_rand.nextBool() ? 1 : -1) * (0.15 + _rand.nextDouble() * 0.4);
//
//     final scale = 0.9 + _rand.nextDouble() * 1.8;
//     final fontSize = 16.0 * scale;
//
//     final opacity = 0.85 + _rand.nextDouble() * 0.15;
//
//     final glyph = glyphs[_rand.nextInt(glyphs.length)];
//     final color = palette[_rand.nextInt(palette.length)];
//
//     return _NoteParticle(
//       x: x,
//       y: y,
//       speed: speed,
//       driftAmp: driftAmp,
//       driftFreq: driftFreq,
//       phase: phase,
//       rotation: _rand.nextDouble() * pi * 2,
//       rotSpeed: rotSpeed,
//       glyph: glyph,
//       color: color.withOpacity(opacity),
//       fontSize: fontSize,
//     );
//   }
//
//   void tick() {
//     if (!_initialized) return;
//     final now = DateTime.now();
//     final dt = now.difference(lastTick).inMilliseconds / 1000.0;
//     lastTick = now;
//
//     for (int i = 0; i < ps.length; i++) {
//       final p = ps[i];
//       p.y += p.speed * dt;
//
//       final t = now.millisecondsSinceEpoch / 1000.0;
//       p.x += sin(t * p.driftFreq + p.phase) * (p.driftAmp * dt);
//
//       p.rotation += p.rotSpeed * dt;
//
//       if (p.y > screen.height + 60) {
//         ps[i] = _randomParticle(startRandomY: false);
//       } else {
//         if (p.x < -40) p.x = screen.width + 40;
//         if (p.x > screen.width + 40) p.x = -40;
//       }
//     }
//   }
// }
//
// class _NoteParticle {
//   double x;
//   double y;
//   double speed;
//   double driftAmp;
//   double driftFreq;
//   double phase;
//
//   double rotation;
//   double rotSpeed;
//
//   final String glyph;
//   final Color color;
//   final double fontSize;
//
//   _NoteParticle({
//     required this.x,
//     required this.y,
//     required this.speed,
//     required this.driftAmp,
//     required this.driftFreq,
//     required this.phase,
//     required this.rotation,
//     required this.rotSpeed,
//     required this.glyph,
//     required this.color,
//     required this.fontSize,
//   });
// }
//
// class _NotesRainPainter extends CustomPainter {
//   final _NotesRain rain;
//   _NotesRainPainter(this.rain);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (!rain._initialized) return;
//
//     for (final p in rain.ps) {
//       final tp = TextPainter(
//         text: TextSpan(
//           text: p.glyph,
//           style: TextStyle(
//             color: p.color,
//             fontSize: p.fontSize,
//             height: 1.0,
//             // fontFamily: 'NotoMusic', // opcional se adicionar a fonte
//           ),
//         ),
//         textDirection: TextDirection.ltr,
//       )..layout();
//
//       final offset = Offset(p.x, p.y);
//       final rectCenter = offset + Offset(tp.width / 2, tp.height / 2);
//
//       canvas.save();
//       canvas.translate(rectCenter.dx, rectCenter.dy);
//       canvas.rotate(p.rotation);
//       canvas.translate(-tp.width / 2, -tp.height / 2);
//
//       final glowPaint = Paint()
//         ..color = p.color.withOpacity(0.22)
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
//       canvas.drawRect(Offset.zero & tp.size, glowPaint);
//
//       tp.paint(canvas, Offset.zero);
//       canvas.restore();
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant _NotesRainPainter oldDelegate) => true;
// }

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
  // Timings: 10s effect, 4s crossfade, 10s content = total 24s
  static const Duration kInitialEffectHold = Duration(seconds: 10);
  static const Duration kCrossFade = Duration(seconds: 4);
  static const Duration kContentVisible = Duration(seconds: 10);
  static final Duration kSplashTotal = kInitialEffectHold + kCrossFade + kContentVisible;

  late final AnimationController _effectOpacityCtrl;
  late final Animation<double> _effectOpacityAnim;
  late final AnimationController _contentOpacityCtrl;
  late final Animation<double> _contentOpacityAnim;

  // ticker to drive animation with real dt
  late final Ticker _ticker;
  DateTime? _lastTickTime;

  // repaint notifier for the CustomPainter
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

    // Ticker: controla dt real e manda repintar via _repaintNotifier
    _ticker = createTicker((elapsed) {
      final now = DateTime.now();
      final last = _lastTickTime ?? now;
      final dt = now.difference(last).inMilliseconds / 1000.0;
      _lastTickTime = now;

      // se ainda não inicializado com tamanho real, tick não fará nada
      _rain.tick(dt);
      // incrementa notifier para forçar repint
      _repaintNotifier.value = _repaintNotifier.value + 1;
    });

    // start ticker **após** primeiro frame (para garantir MediaQuery disponível)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // initialize rain with actual size immediately
      final sz = MediaQuery.of(context).size;
      _rain.ensureInitialized(sz);
      _lastTickTime = DateTime.now();
      _ticker.start();
    });

    // iniciar crossfade após hold
    _startCrossFadeTimer = Timer(kInitialEffectHold, () {
      _contentOpacityCtrl.forward();
      _effectOpacityCtrl.forward();
    });

    _navTimer = Timer(kSplashTotal, () {
      if (!mounted) return;
      // stop ticker
      _ticker.stop();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Loginscreen()));
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _startCrossFadeTimer?.cancel();
    _ticker.dispose();
    _effectOpacityCtrl.dispose();
    _contentOpacityCtrl.dispose();
    _repaintNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    // fallback ensureInitialized in case MediaQuery changed (safe no-op)
    _rain.ensureInitialized(MediaQuery.of(context).size);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(fit: StackFit.expand, children: [
        // efeito por baixo — controlamos a opacidade via AnimatedBuilder
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

        // conteúdo central (imagem + título + slogan) — aparece gradualmente
        Center(
          child: FadeTransition(
            opacity: _contentOpacityAnim,
            child: _buildContent(primary),
          ),
        ),
      ]),
    );
  }

  Widget _buildContent(Color primary) {
    const title = 'HOSANA PROJECTO CRISTÃO';
    const slogan = 'Adorando juntos em qualquer lugar, unidos pela fé, conectados em Cristo';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // logo fixo
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
/// Hacker-like falling text effect (full-screen orange lines)
/// The tick(dt) now uses real dt passed by the Ticker (seconds)
/// =======================

class _HackerRain {
  _HackerRain({int? seed}) : _rand = Random(seed);

  final Random _rand;
  late Size screen;
  bool _initialized = false;

  // characters source (uppercase letters without spaces)
  static const String slogan = 'AGUINALDODEJESUS';
  static const String fallback = 'MARTINSMADEIRA';
  late final List<String> _chars;

  final List<_HackerColumn> cols = [];
  late List<Color> palette;

  static const double _colWidth = 20.0;
  static const int _minCols = 8;

  void ensureInitialized(Size s) {
    if (_initialized && screen == s) return;
    screen = s;

    final base = slogan.isEmpty ? fallback : slogan;
    _chars = base.split('');

    final baseColor = const Color(0xFFEC8A00); // strong orange
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

  /// tick with real dt in seconds
  void tick(double dt) {
    if (!_initialized) return;
    for (final c in cols) c.tick(dt);
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
  double speed = 60.0; // px/sec baseline
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
    speed = 40 + rand.nextDouble() * 180; // px/sec
    length = 6 + rand.nextInt(12);
    charHeight = 12 + rand.nextDouble() * 14;
    opacity = 0.65 + rand.nextDouble() * 0.4;
    ticksSinceReset = rand.nextInt(1000);
    active = true;
  }

  /// tick accepts dt in seconds
  void tick(double dt) {
    if (!active) return;
    headY += speed * dt;
    ticksSinceReset++;

    // small random pauses to naturalize motion
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
        final alphaFactor = col.opacity * (1.0 - i / len * 0.9);

        textPainter.text = TextSpan(
          text: ch,
          style: TextStyle(
            color: baseColor.withOpacity(alphaFactor.clamp(0.05, 1.0)),
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
  bool shouldRepaint(covariant _HackerRainPainter oldDelegate) => true;
}
