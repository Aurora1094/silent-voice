import 'dart:ui';

import 'package:flutter/material.dart';

import '../course_map/monument_course_map_screen.dart';

class ImmersiveHomeScreen extends StatelessWidget {
  final VoidCallback onPracticeTap;
  final VoidCallback onLessonsTap;
  final VoidCallback onStoryTap;
  final Widget bottomNav;

  const ImmersiveHomeScreen({
    super.key,
    required this.onPracticeTap,
    required this.onLessonsTap,
    required this.onStoryTap,
    required this.bottomNav,
  });

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final progress = _LearningProgress.fromLessons(courseMapLessons);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 780 || constraints.maxWidth < 390;
        final extraCompact = constraints.maxHeight < 700;
        final gap = extraCompact ? 10.0 : 14.0;
        final horizontalPadding = compact ? 18.0 : 20.0;
        final topInset = viewPadding.top + (compact ? 12.0 : 18.0);
        final bottomInset = viewPadding.bottom + 14.0;
        final buttonHeight = compact ? 52.0 : 58.0;

        return Stack(
          children: [
            const Positioned.fill(child: _HomeAtmosphere()),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topInset,
                  horizontalPadding,
                  bottomInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _PillTag(
                              text: 'CV 手语识别 × 沉浸式教学',
                              solid: true,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        _PillTag(
                          text: '愿每一个手势都被看见',
                          solid: false,
                        ),
                      ],
                    ),
                    SizedBox(height: gap),
                    Expanded(
                      flex: extraCompact ? 42 : 46,
                      child: _HeroMonumentPanel(
                        compact: compact,
                        onStoryTap: onStoryTap,
                      ),
                    ),
                    SizedBox(height: gap),
                    SizedBox(
                      height: buttonHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: _PrimaryActionButton(
                              label: '开始练习',
                              compact: compact,
                              onTap: onPracticeTap,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _GlassActionButton(
                              label: '课程地图',
                              compact: compact,
                              onTap: onLessonsTap,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: gap),
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            '今日旅程',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF27314F),
                            ),
                          ),
                        ),
                        Text(
                          'Monument Valley Mood',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7B85A2),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: gap),
                    Expanded(
                      flex: extraCompact ? 26 : 24,
                      child: Row(
                        children: const [
                          Expanded(
                            child: _JourneyGlassCard(
                              title: '基础手势',
                              description: '从问候、感谢等高频手势开始，建立最自然的表达感。',
                              icon: Icons.sign_language_rounded,
                              accent: Color(0xFFFFD6C8),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _JourneyGlassCard(
                              title: '实时识别',
                              description: '用镜头捕捉动作细节，边练边看反馈，让学习更有陪伴感。',
                              icon: Icons.camera_alt_outlined,
                              accent: Color(0xFFD7E7FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: gap),
                    Expanded(
                      flex: extraCompact ? 32 : 30,
                      child: _LearningProgressCard(
                        compact: compact,
                        progress: progress,
                        onLessonsTap: onLessonsTap,
                      ),
                    ),
                    SizedBox(height: gap),
                    bottomNav,
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LearningProgress {
  final double overallValue;
  final int completedCount;
  final int totalCount;
  final int unlockedCount;
  final CourseMapLesson currentLesson;
  final CourseMapLesson? nextLesson;

  const _LearningProgress({
    required this.overallValue,
    required this.completedCount,
    required this.totalCount,
    required this.unlockedCount,
    required this.currentLesson,
    required this.nextLesson,
  });

  int get percent => (overallValue * 100).round();

  factory _LearningProgress.fromLessons(List<CourseMapLesson> lessons) {
    final completedCount = lessons
        .where((lesson) => lesson.state == CourseMapLessonState.completed)
        .length;
    final unlockedCount = lessons.where((lesson) => !lesson.locked).length;
    final currentLesson = lessons.firstWhere(
      (lesson) => lesson.current,
      orElse: () => lessons.first,
    );
    final nextLesson = lessons.cast<CourseMapLesson?>().firstWhere(
          (lesson) => lesson?.state == CourseMapLessonState.upcoming,
          orElse: () => null,
        );

    double score = 0;
    for (final lesson in lessons) {
      switch (lesson.state) {
        case CourseMapLessonState.completed:
          score += 1;
          break;
        case CourseMapLessonState.current:
          score += lesson.progressValue.clamp(0.0, 1.0);
          break;
        case CourseMapLessonState.upcoming:
          score += lesson.progressValue.clamp(0.0, 0.2);
          break;
        case CourseMapLessonState.locked:
          break;
      }
    }

    return _LearningProgress(
      overallValue: (score / lessons.length).clamp(0.0, 1.0),
      completedCount: completedCount,
      totalCount: lessons.length,
      unlockedCount: unlockedCount,
      currentLesson: currentLesson,
      nextLesson: nextLesson,
    );
  }
}

class _HomeAtmosphere extends StatelessWidget {
  const _HomeAtmosphere();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE7DDFB),
            Color(0xFFEDE8FF),
            Color(0xFFE9F4FF),
            Color(0xFFFFEFE7),
          ],
          stops: [0.0, 0.32, 0.68, 1.0],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: -26,
            right: -14,
            child: _BlurBlob(
              size: 170,
              colors: [Color(0xFFFFE8A8), Color(0xFFFFD59A)],
              opacity: 0.82,
            ),
          ),
          Positioned(
            top: 120,
            left: -72,
            child: _BlurBlob(
              size: 214,
              colors: [Color(0xFFD9CEF8), Color(0xFFC7DFFF)],
              opacity: 0.46,
            ),
          ),
          Positioned(
            bottom: 112,
            right: -56,
            child: _BlurBlob(
              size: 220,
              colors: [Color(0xFFFFD9CF), Color(0xFFE5D7FF)],
              opacity: 0.42,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final double opacity;

  const _BlurBlob({
    required this.size,
    required this.colors,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: colors),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroMonumentPanel extends StatelessWidget {
  final bool compact;
  final VoidCallback onStoryTap;

  const _HeroMonumentPanel({
    required this.compact,
    required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.all(compact ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.34),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.66),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B4263).withOpacity(0.08),
                blurRadius: 26,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final titleSize = compact ? 32.0 : 38.0;
              final paragraphSize = compact ? 13.0 : 14.0;
              return Row(
                children: [
                  Expanded(
                    flex: 11,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.white.withOpacity(0.68),
                          ),
                          child: const Text(
                            'Silent Voice',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A5677),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '让我听见你',
                          style: TextStyle(
                            fontSize: titleSize,
                            height: 1.02,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: const Color(0xFF27314F),
                          ),
                        ),
                        SizedBox(height: compact ? 10 : 12),
                        Text(
                          '一款温柔、沉浸的手语学习 App。用镜头理解动作，用柔和的界面陪你从“看见手势”走向“真正表达”。',
                          maxLines: compact ? 4 : 5,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: paragraphSize,
                            height: 1.65,
                            color: const Color(0xFF66708D),
                          ),
                        ),
                        SizedBox(height: compact ? 12 : 14),
                        _CompactGlassButton(
                          label: '手语故事',
                          compact: compact,
                          onTap: onStoryTap,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: compact ? 10 : 14),
                  Expanded(
                    flex: 9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.24),
                            Colors.white.withOpacity(0.10),
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: _MonumentHeroPainter(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PillTag extends StatelessWidget {
  final String text;
  final bool solid;

  const _PillTag({
    required this.text,
    required this.solid,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: solid
                ? Colors.white.withOpacity(0.82)
                : Colors.white.withOpacity(0.40),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withOpacity(0.65),
              width: 1,
            ),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: solid ? const Color(0xFF4A5677) : const Color(0xFF5F6A89),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final bool compact;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.label,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFC3AF), Color(0xFFFFD8C6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB97D75).withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: compact ? 15 : 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E3557),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  final String label;
  final bool compact;
  final VoidCallback onTap;

  const _GlassActionButton({
    required this.label,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.42),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.65),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 15 : 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4C5778),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyGlassCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accent;

  const _JourneyGlassCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.42),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.68),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B4263).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.86),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: const Color(0xFF3E4A68),
                ),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF27314F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.6,
                  color: Color(0xFF68728F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningProgressCard extends StatelessWidget {
  final bool compact;
  final _LearningProgress progress;
  final VoidCallback onLessonsTap;

  const _LearningProgressCard({
    required this.compact,
    required this.progress,
    required this.onLessonsTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.all(compact ? 16 : 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.42),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.68),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B4263).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '学习进度',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF27314F),
                      ),
                    ),
                  ),
                  Text(
                    '${progress.percent}%',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF27314F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '已完成 ${progress.completedCount}/${progress.totalCount} 节，当前正在学习「${progress.currentLesson.title}」',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.6,
                  color: Color(0xFF66708D),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.overallValue,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.44),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFC5B5),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _ProgressMetricChip(
                      label: '已解锁',
                      value: '${progress.unlockedCount} 节',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ProgressMetricChip(
                      label: '下一节',
                      value: progress.nextLesson?.title ?? '继续当前课程',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CompactGlassButton(
                      label: '查看地图',
                      compact: compact,
                      onTap: onLessonsTap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressMetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _ProgressMetricChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.46),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF7A849F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF394260),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactGlassButton extends StatelessWidget {
  final String label;
  final bool compact;
  final VoidCallback onTap;

  const _CompactGlassButton({
    required this.label,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: compact ? 10 : 11,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.50),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.70),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 12.5 : 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF44506E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapScale({
    required this.child,
    required this.onTap,
  });

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _pressed ? 0.97 : 1,
        child: widget.child,
      ),
    );
  }
}

class _MonumentHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF0C4), Color(0x00FFF0C4)],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.82, size.height * 0.12),
        radius: size.width * 0.20,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.12),
      size.width * 0.18,
      sunPaint,
    );

    final mistPaint = Paint()..color = Colors.white.withOpacity(0.16);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.30, size.height * 0.84),
        width: size.width * 0.62,
        height: size.height * 0.10,
      ),
      mistPaint,
    );

    _drawTower(
      canvas,
      rect: Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.52,
        size.width * 0.14,
        size.height * 0.26,
      ),
      top: const Color(0xFFF7E8D7),
      front: const Color(0xFFEFA9A4),
      side: const Color(0xFFD78C96),
    );
    _drawTower(
      canvas,
      rect: Rect.fromLTWH(
        size.width * 0.64,
        size.height * 0.44,
        size.width * 0.13,
        size.height * 0.30,
      ),
      top: const Color(0xFFF7E8D8),
      front: const Color(0xFFE8A39D),
      side: const Color(0xFFD48893),
    );
    _drawTower(
      canvas,
      rect: Rect.fromLTWH(
        size.width * 0.26,
        size.height * 0.22,
        size.width * 0.32,
        size.height * 0.48,
      ),
      top: const Color(0xFFF8E7D7),
      front: const Color(0xFFD8D1F0),
      side: const Color(0xFFBAB2DB),
    );

    final archPaint = Paint()
      ..color = const Color(0xFFF0C9BF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;
    final arch = Path()
      ..moveTo(size.width * 0.35, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.48,
        size.width * 0.43,
        size.height * 0.43,
      )
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.48,
        size.width * 0.51,
        size.height * 0.62,
      );
    canvas.drawPath(arch, archPaint);
    canvas.drawLine(
      Offset(size.width * 0.43, size.height * 0.43),
      Offset(size.width * 0.43, size.height * 0.70),
      Paint()
        ..color = const Color(0xFFF0C9BF)
        ..strokeWidth = size.width * 0.034
        ..strokeCap = StrokeCap.round,
    );

    _drawBridge(
      canvas,
      Offset(size.width * 0.18, size.height * 0.60),
      Offset(size.width * 0.33, size.height * 0.52),
    );
    _drawBridge(
      canvas,
      Offset(size.width * 0.57, size.height * 0.56),
      Offset(size.width * 0.70, size.height * 0.56),
    );

    _drawStairs(
      canvas,
      Offset(size.width * 0.18, size.height * 0.61),
      stepWidth: size.width * 0.055,
      steps: 9,
      tilt: -1,
    );
    _drawStairs(
      canvas,
      Offset(size.width * 0.68, size.height * 0.58),
      stepWidth: size.width * 0.055,
      steps: 9,
      tilt: 1,
    );

    final personPaint = Paint()..color = const Color(0xFF36405D);
    canvas.drawCircle(
      Offset(size.width * 0.46, size.height * 0.79),
      size.width * 0.014,
      personPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.46, size.height * 0.82),
        width: size.width * 0.018,
        height: size.height * 0.04,
      ),
      personPaint,
    );

    final glowPaint = Paint()
      ..color = const Color(0xFFFFD684).withOpacity(0.72)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(
      Offset(size.width * 0.71, size.height * 0.43),
      size.width * 0.03,
      glowPaint,
    );
  }

  void _drawTower(
    Canvas canvas, {
    required Rect rect,
    required Color top,
    required Color front,
    required Color side,
  }) {
    final skew = rect.width * 0.22;
    final topFace = Path()
      ..moveTo(rect.left + skew, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right - skew, rect.top + rect.height * 0.12)
      ..lineTo(rect.left, rect.top + rect.height * 0.12)
      ..close();
    final frontFace = Path()
      ..moveTo(rect.left, rect.top + rect.height * 0.12)
      ..lineTo(rect.right - skew, rect.top + rect.height * 0.12)
      ..lineTo(rect.right - skew, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
    final sideFace = Path()
      ..moveTo(rect.right, rect.top)
      ..lineTo(rect.right - skew, rect.top + rect.height * 0.12)
      ..lineTo(rect.right - skew, rect.bottom)
      ..lineTo(rect.right, rect.bottom - rect.height * 0.12)
      ..close();

    canvas.drawShadow(frontFace, const Color(0x1A2E3557), 16, false);
    canvas.drawPath(topFace, Paint()..color = top);
    canvas.drawPath(frontFace, Paint()..color = front);
    canvas.drawPath(sideFace, Paint()..color = side);
  }

  void _drawBridge(Canvas canvas, Offset start, Offset end) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        (start.dx + end.dx) / 2,
        start.dy - 8,
        (start.dx + end.dx) / 2,
        end.dy + 8,
        end.dx,
        end.dy,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x14FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFF7E8D8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawStairs(
    Canvas canvas,
    Offset start, {
    required double stepWidth,
    required int steps,
    required int tilt,
  }) {
    final paint = Paint()
      ..color = const Color(0xFFF7ECDD)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < steps; index++) {
      final dx = index * (tilt * 4.0);
      final dy = index * 5.0;
      canvas.drawLine(
        Offset(start.dx + dx, start.dy + dy),
        Offset(start.dx + dx + stepWidth, start.dy + dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
