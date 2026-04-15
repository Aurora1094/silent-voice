import 'dart:ui';

import 'package:flutter/material.dart';

enum CourseMapLessonState { completed, current, upcoming, locked }

class CourseMapLesson {
  final String chapter;
  final String title;
  final String subtitle;
  final String duration;
  final String description;
  final IconData icon;
  final String progressLabel;
  final String difficulty;
  final double progressValue;
  final int steps;
  final List<Color> colors;
  final int lane;
  final double xAlign;
  final double top;
  final CourseMapLessonState state;

  const CourseMapLesson({
    required this.chapter,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.description,
    required this.icon,
    required this.progressLabel,
    required this.difficulty,
    required this.progressValue,
    required this.steps,
    required this.colors,
    required this.lane,
    required this.xAlign,
    required this.top,
    required this.state,
  });

  bool get locked => state == CourseMapLessonState.locked;
  bool get current => state == CourseMapLessonState.current;

  String get stateLabel {
    switch (state) {
      case CourseMapLessonState.completed:
        return '已完成';
      case CourseMapLessonState.current:
        return '学习中';
      case CourseMapLessonState.upcoming:
        return '待开始';
      case CourseMapLessonState.locked:
        return '未解锁';
    }
  }
}

const List<CourseMapLesson> courseMapLessons = [
  CourseMapLesson(
    chapter: '第一章',
    title: '你好',
    subtitle: '基础问候',
    duration: '06 min',
    description: '从手掌朝向和节奏开始，建立最自然的问候表达。',
    icon: Icons.front_hand_rounded,
    progressLabel: '起始课程',
    difficulty: '入门',
    progressValue: 1,
    steps: 5,
    colors: [Color(0xFFF9C8B2), Color(0xFFFFE7DA)],
    lane: 0,
    xAlign: 0.14,
    top: 82,
    state: CourseMapLessonState.completed,
  ),
  CourseMapLesson(
    chapter: '第一章',
    title: '谢谢',
    subtitle: '礼貌回应',
    duration: '08 min',
    description: '练习从下巴前方轻柔送出的轨迹，让动作更稳定。',
    icon: Icons.favorite_outline_rounded,
    progressLabel: '发音与节奏',
    difficulty: '入门',
    progressValue: 1,
    steps: 6,
    colors: [Color(0xFFF5D76C), Color(0xFFFFF0C9)],
    lane: 1,
    xAlign: 0.72,
    top: 334,
    state: CourseMapLessonState.completed,
  ),
  CourseMapLesson(
    chapter: '第一章',
    title: '我',
    subtitle: '自我表达',
    duration: '07 min',
    description: '认识指向自身的表达方式，避免角度漂移和抖动。',
    icon: Icons.person_rounded,
    progressLabel: '当前学习',
    difficulty: '基础',
    progressValue: 0.62,
    steps: 4,
    colors: [Color(0xFF8FD6C1), Color(0xFFD7F4E7)],
    lane: 2,
    xAlign: 0.43,
    top: 678,
    state: CourseMapLessonState.current,
  ),
  CourseMapLesson(
    chapter: '第一章',
    title: '喜欢',
    subtitle: '情绪表达',
    duration: '09 min',
    description: '把动作与表情联系起来，让表达更自然、更完整。',
    icon: Icons.star_rounded,
    progressLabel: '下一节',
    difficulty: '基础',
    progressValue: 0.12,
    steps: 7,
    colors: [Color(0xFFD8CCF6), Color(0xFFF0E8FF)],
    lane: 1,
    xAlign: 0.30,
    top: 936,
    state: CourseMapLessonState.upcoming,
  ),
  CourseMapLesson(
    chapter: '第一章',
    title: '你还好吗',
    subtitle: '关怀句式',
    duration: '10 min',
    description: '把基础词汇连接成完整问句，进入更真实的交流语境。',
    icon: Icons.chat_bubble_outline_rounded,
    progressLabel: '即将解锁',
    difficulty: '进阶',
    progressValue: 0.05,
    steps: 8,
    colors: [Color(0xFFF7C9CB), Color(0xFFFFE6E8)],
    lane: 2,
    xAlign: 0.72,
    top: 1108,
    state: CourseMapLessonState.upcoming,
  ),
  CourseMapLesson(
    chapter: '第一章',
    title: '一起练习',
    subtitle: '章节综合',
    duration: '12 min',
    description: '完成前置课程后，进入完整连续表达的综合练习。',
    icon: Icons.auto_awesome_rounded,
    progressLabel: '综合关卡',
    difficulty: '进阶',
    progressValue: 0,
    steps: 10,
    colors: [Color(0xFFCCC7E3), Color(0xFFEAE7F3)],
    lane: 0,
    xAlign: 0.18,
    top: 1332,
    state: CourseMapLessonState.locked,
  ),
];

class MonumentCourseMapScreen extends StatefulWidget {
  final ValueChanged<int> onTabChanged;

  const MonumentCourseMapScreen({
    super.key,
    required this.onTabChanged,
  });

  @override
  State<MonumentCourseMapScreen> createState() =>
      _MonumentCourseMapScreenState();
}

class _MonumentCourseMapScreenState extends State<MonumentCourseMapScreen> {
  static const double _mapWidth = 760;
  static const double _mapHeight = 1620;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final completedCount = courseMapLessons
        .where((lesson) => lesson.state == CourseMapLessonState.completed)
        .length;
    final currentLesson = courseMapLessons.firstWhere(
      (lesson) => lesson.state == CourseMapLessonState.current,
      orElse: () => courseMapLessons.first,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapScale = constraints.maxWidth / _mapWidth;
        final scaledMapHeight = _mapHeight * mapScale;
        final topOverlayHeight = viewPadding.top + 160.0;
        final bottomOverlayHeight = viewPadding.bottom + 110.0;

        return Stack(
          children: [
            const Positioned.fill(child: _CourseMapBackground()),
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: topOverlayHeight,
                  bottom: bottomOverlayHeight,
                ),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: scaledMapHeight,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: _mapWidth,
                      height: _mapHeight,
                      child: Stack(
                        children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CourseMapScenePainter(courseMapLessons),
                        ),
                      ),
                      const Positioned(
                        left: 152,
                        top: 138,
                        child: _MainMonumentCluster(),
                      ),
                      const Positioned(
                        left: 6,
                        top: 96,
                        child: _ReflectivePool(),
                      ),
                      const Positioned(
                        left: 22,
                        top: 832,
                        child: _ReflectivePool(),
                      ),
                      const Positioned(
                        right: 22,
                        top: 96,
                        child: _MiniTower(),
                      ),
                      for (final lesson in courseMapLessons)
                        Positioned(
                          left: (_mapWidth * lesson.xAlign) - 68,
                          top: lesson.top,
                          child: _CourseMapNode(
                            lesson: lesson,
                                onTap: () => _showLessonSheet(context, lesson),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: viewPadding.top + 12,
              child: Row(
                children: [
                  const _GlassPill(
                    icon: Icons.map_outlined,
                    text: '课程地图',
                  ),
                  const Spacer(),
                  _GlassPill(
                    icon: Icons.layers_outlined,
                    text: '已完成 $completedCount/${courseMapLessons.length}',
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: viewPadding.top + 64,
              child: _CourseSummaryHeader(
                currentLesson: currentLesson,
                completedCount: completedCount,
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: viewPadding.bottom + 14,
              child: _CourseMapBottomNav(
                currentIndex: 1,
                onChanged: widget.onTabChanged,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLessonSheet(BuildContext context, CourseMapLesson lesson) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.12),
      enableDrag: true,
      isDismissible: true,
      builder: (_) => _CourseDetailSheet(lesson: lesson),
    );
  }
}

class _CourseMapBackground extends StatelessWidget {
  const _CourseMapBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE7DDFB),
            Color(0xFFF0E8FF),
            Color(0xFFEAF4FF),
            Color(0xFFFFEEE7),
          ],
          stops: [0.0, 0.32, 0.68, 1.0],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: -42,
            right: -6,
            child: _BlurBlob(
              size: 184,
              colors: [Color(0xFFFFE7A6), Color(0xFFFFD696)],
              opacity: 0.88,
            ),
          ),
          Positioned(
            top: 126,
            left: -90,
            child: _BlurBlob(
              size: 228,
              colors: [Color(0xFFD7CEF9), Color(0xFFC6DBFF)],
              opacity: 0.48,
            ),
          ),
          Positioned(
            bottom: 116,
            right: -60,
            child: _BlurBlob(
              size: 236,
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
          imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
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

class _CourseSummaryHeader extends StatelessWidget {
  final CourseMapLesson currentLesson;
  final int completedCount;

  const _CourseSummaryHeader({
    required this.currentLesson,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = completedCount / courseMapLessons.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.34),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.62),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '今日旅程',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF28324E),
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF28324E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '当前课程：${currentLesson.subtitle} · ${currentLesson.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF66708D),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.44),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFC8B7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseMapNode extends StatefulWidget {
  final CourseMapLesson lesson;
  final VoidCallback onTap;

  const _CourseMapNode({
    required this.lesson,
    required this.onTap,
  });

  @override
  State<_CourseMapNode> createState() => _CourseMapNodeState();
}

class _CourseMapNodeState extends State<_CourseMapNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.lesson.current) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant _CourseMapNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lesson.current && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.lesson.current && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final locked = lesson.locked;
    final completed = lesson.state == CourseMapLessonState.completed;
    final current = lesson.current;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = current ? 0.72 + (_controller.value * 0.28) : 0.38;
        return GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            width: 154,
            child: Column(
              children: [
                SizedBox(
                  width: 154,
                  height: 154,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        bottom: 14,
                        child: CustomPaint(
                          size: const Size(136, 96),
                          painter: _NodePedestalPainter(
                            topColor: locked
                                ? const Color(0xFFEAE5EF)
                                : lesson.colors.last,
                            frontColor: locked
                                ? const Color(0xFFD8D3DE)
                                : lesson.colors.first.withOpacity(0.86),
                            sideColor: locked
                                ? const Color(0xFFC3BCCB)
                                : (lesson.lane == 1
                                        ? const Color(0xFFF0C35F)
                                        : lesson.lane == 2
                                            ? const Color(0xFFD3BFE8)
                                            : const Color(0xFFF09B84))
                                    .withOpacity(0.78),
                          ),
                        ),
                      ),
                      Positioned(
                        top: current ? 10 : 6,
                        child: _NodeTotem(
                          lesson: lesson,
                          glow: glow,
                        ),
                      ),
                      if (completed)
                        Positioned(
                          right: 8,
                          top: 20,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFE184).withOpacity(0.92),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFE184).withOpacity(0.44),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                            child: Icon(
                              completed && lesson.title == '谢谢'
                                  ? Icons.check_rounded
                                  : Icons.auto_awesome_rounded,
                              size: 19,
                              color: const Color(0xFF6B5B37),
                            ),
                          ),
                        ),
                      if (current)
                        Positioned(
                          right: 10,
                          bottom: 16,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFC8AF).withOpacity(0.96),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFC8AF).withOpacity(0.34),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 22,
                              color: Color(0xFF7E5E57),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  constraints: const BoxConstraints(maxWidth: 110),
                  padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white.withOpacity(0.64),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.70),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    lesson.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: locked
                          ? const Color(0xFF8B8795)
                          : const Color(0xFF36405D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NodePedestalPainter extends CustomPainter {
  final Color topColor;
  final Color frontColor;
  final Color sideColor;

  const _NodePedestalPainter({
    required this.topColor,
    required this.frontColor,
    required this.sideColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final skew = size.width * 0.18;
    final topSlabHeight = size.height * 0.24;
    final bodyTop = size.height * 0.30;
    final slabGap = size.height * 0.06;
    final slabTopFace = Path()
      ..moveTo(skew, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - skew, topSlabHeight)
      ..lineTo(0, topSlabHeight)
      ..close();
    final slabFrontFace = Path()
      ..moveTo(0, topSlabHeight)
      ..lineTo(size.width - skew, topSlabHeight)
      ..lineTo(size.width - skew, topSlabHeight + slabGap)
      ..lineTo(0, topSlabHeight + slabGap)
      ..close();
    final topFace = Path()
      ..moveTo(skew, bodyTop)
      ..lineTo(size.width, bodyTop)
      ..lineTo(size.width - skew, bodyTop + size.height * 0.22)
      ..lineTo(0, bodyTop + size.height * 0.22)
      ..close();
    final frontFace = Path()
      ..moveTo(0, bodyTop + size.height * 0.22)
      ..lineTo(size.width - skew, bodyTop + size.height * 0.22)
      ..lineTo(size.width - skew, size.height)
      ..lineTo(0, size.height)
      ..close();
    final sideFace = Path()
      ..moveTo(size.width, bodyTop)
      ..lineTo(size.width - skew, bodyTop + size.height * 0.22)
      ..lineTo(size.width - skew, size.height)
      ..lineTo(size.width, size.height * 0.78)
      ..close();

    canvas.drawShadow(frontFace, const Color(0x162E3557), 12, false);
    canvas.drawPath(slabTopFace, Paint()..color = Colors.white.withOpacity(0.92));
    canvas.drawPath(
      slabFrontFace,
      Paint()..color = topColor.withOpacity(0.82),
    );
    canvas.drawPath(topFace, Paint()..color = topColor);
    canvas.drawPath(frontFace, Paint()..color = frontColor);
    canvas.drawPath(sideFace, Paint()..color = sideColor);
  }

  @override
  bool shouldRepaint(covariant _NodePedestalPainter oldDelegate) =>
      oldDelegate.topColor != topColor ||
      oldDelegate.frontColor != frontColor ||
      oldDelegate.sideColor != sideColor;
}

class _NodeTotem extends StatelessWidget {
  final CourseMapLesson lesson;
  final double glow;

  const _NodeTotem({
    required this.lesson,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    final locked = lesson.locked;
    if (lesson.current) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF2D8), Color(0xFFF6C7A8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD7B6).withOpacity(0.50),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 86,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lesson.colors.last.withOpacity(0.96),
                  lesson.colors.first.withOpacity(0.96),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: lesson.colors.first.withOpacity(glow * 0.42),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 14,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF6C7B83).withOpacity(0.55),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      width: 40,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: locked
              ? const [Color(0xFFE7E1ED), Color(0xFFD8D2DE)]
              : [
                  lesson.colors.last.withOpacity(0.98),
                  lesson.colors.first.withOpacity(0.98),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (locked ? const Color(0xFFC4BECD) : lesson.colors.first)
                .withOpacity(glow * 0.42),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!locked && lesson.title == '谢谢')
            const Icon(
              Icons.auto_awesome_rounded,
              size: 22,
              color: Color(0xFFF0C749),
            ),
          if (!locked && lesson.title == '谢谢') const SizedBox(height: 4),
          Container(
            width: 14,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF6C6876).withOpacity(0.48),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseDetailSheet extends StatelessWidget {
  final CourseMapLesson lesson;

  const _CourseDetailSheet({
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final buttonColors = lesson.locked
        ? const [Color(0xFFE0DCE8), Color(0xFFD1CBDC)]
        : lesson.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + viewPadding.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.60),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                color: Colors.white.withOpacity(0.74),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF36415F).withOpacity(0.14),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: const Color(0xFFB8BED2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: lesson.locked
                              ? const Color(0xFFD9D3E2)
                              : lesson.colors.first.withOpacity(0.88),
                        ),
                        child: Icon(
                          lesson.locked
                              ? Icons.lock_outline_rounded
                              : lesson.icon,
                          size: 28,
                          color: const Color(0xFF4B5574),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${lesson.chapter} · ${lesson.subtitle}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6A7591),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lesson.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF28324E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    lesson.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: Color(0xFF66708D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _LessonMetric(
                          label: '进度',
                          value: lesson.progressLabel,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LessonMetric(
                          label: '难度',
                          value: lesson.difficulty,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LessonMetric(
                          label: '时长',
                          value: lesson.duration,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: buttonColors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: buttonColors.first.withOpacity(0.28),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => Navigator.of(context).pop(),
                        child: Center(
                          child: Text(
                            lesson.locked ? '完成前置课程后解锁' : '开始学习',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: lesson.locked
                                  ? const Color(0xFF847F8F)
                                  : const Color(0xFF2E3557),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonMetric extends StatelessWidget {
  final String label;
  final String value;

  const _LessonMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.48),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
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

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.white.withOpacity(0.38),
            border: Border.all(
              color: Colors.white.withOpacity(0.68),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: const Color(0xFF4D5776),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4D5776),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseMapBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _CourseMapBottomNav({
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, '首页'),
      (Icons.map_outlined, '课程'),
      (Icons.center_focus_strong_rounded, '练习'),
      (Icons.chat_bubble_outline_rounded, '故事'),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.34),
            border: Border.all(
              color: Colors.white.withOpacity(0.58),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E3557).withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final active = currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: active
                          ? Colors.white.withOpacity(0.54)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          items[index].$1,
                          size: 22,
                          color: active
                              ? const Color(0xFF2E3557)
                              : const Color(0xFF5F678F),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[index].$2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            color: active
                                ? const Color(0xFF2E3557)
                                : const Color(0xFF5F678F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _MainMonumentCluster extends StatelessWidget {
  const _MainMonumentCluster();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 430,
      height: 760,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 116,
            top: 32,
            child: Container(
              width: 176,
              height: 520,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(72),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF4C7B7).withOpacity(0.78),
                    const Color(0xFFDCC3DA).withOpacity(0.74),
                    const Color(0xFFC7C5EE).withOpacity(0.68),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB391C3).withOpacity(0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 96,
                    left: 0,
                    right: 0,
                    child: Text(
                      'SILENT\nVOICE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.0,
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                        color: Colors.white.withOpacity(0.86),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 38,
                    right: 38,
                    bottom: 78,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 20,
                          height: 164,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.42),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 164,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.42),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 53,
                    right: 53,
                    bottom: 34,
                    child: Container(
                      height: 112,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.40),
                          width: 14,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(54),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 314,
            top: 112,
            child: Container(
              width: 34,
              height: 242,
              decoration: BoxDecoration(
                color: const Color(0xFFA8A6E4).withOpacity(0.58),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Positioned(
            left: 74,
            top: 514,
            child: Container(
              width: 180,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF9E3D1), Color(0xFFEFD8C8)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 176,
            bottom: 148,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8D8EAF).withOpacity(0.64),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IsoTower extends StatelessWidget {
  final double width;
  final double height;
  final Color topColor;
  final Color frontColor;
  final Color sideColor;
  final String? title;

  const _IsoTower({
    required this.width,
    required this.height,
    required this.topColor,
    required this.frontColor,
    required this.sideColor,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final skew = width * 0.22;
    return SizedBox(
      width: width + skew,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: skew,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [frontColor.withOpacity(0.94), frontColor],
                ),
              ),
              child: title == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(top: height * 0.18),
                      child: Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.1,
                          fontSize: width * 0.16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.3,
                          color: Colors.white.withOpacity(0.90),
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            left: 0,
            top: height * 0.08,
            bottom: 0,
            child: ClipPath(
              clipper: _LeftFaceClipper(skew),
              child: Container(
                width: skew + 24,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: sideColor,
                ),
              ),
            ),
          ),
          Positioned(
            left: skew - 10,
            right: 0,
            top: 0,
            child: ClipPath(
              clipper: _TopFaceClipper(),
              child: Container(
                height: height * 0.14,
                decoration: BoxDecoration(
                  color: topColor,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTower extends StatelessWidget {
  const _MiniTower();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144,
      height: 350,
      child: Stack(
        children: [
          Positioned(
            right: 12,
            top: 0,
            child: Container(
              width: 78,
              height: 228,
              decoration: BoxDecoration(
                color: const Color(0xFF9CD8EA).withOpacity(0.58),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Positioned(
            right: 36,
            top: 18,
            child: Container(
              width: 54,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF6EA7BA).withOpacity(0.92),
              ),
            ),
          ),
          Positioned(
            right: 64,
            top: 94,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7AD4D3).withOpacity(0.54),
              ),
            ),
          ),
          Positioned(
            right: 64,
            top: 142,
            child: Container(
              width: 36,
              height: 118,
              decoration: BoxDecoration(
                color: const Color(0xFFDE9B92).withOpacity(0.58),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 208,
            child: SizedBox(
              width: 86,
              height: 56,
              child: CustomPaint(
                painter: _NodePedestalPainter(
                  topColor: const Color(0xFFFCE6D8),
                  frontColor: const Color(0xFFF4C8BF),
                  sideColor: const Color(0xFFD37D79),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectivePool extends StatelessWidget {
  const _ReflectivePool();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 280,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 34,
            child: Container(
              width: 126,
              height: 210,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                border: Border.all(
                  color: Colors.white.withOpacity(0.34),
                  width: 4,
                ),
                color: Colors.white.withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.16),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 0,
            child: SizedBox(
              width: 112,
              height: 96,
              child: CustomPaint(
                painter: _NodePedestalPainter(
                  topColor: const Color(0xFFFDE5D8),
                  frontColor: const Color(0xFFF6D5C7),
                  sideColor: const Color(0xFFF1997F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftFaceClipper extends CustomClipper<Path> {
  final double skew;

  const _LeftFaceClipper(this.skew);

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(skew, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - skew, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _TopFaceClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.18, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.82, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF0C9BF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height)
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.44,
        size.width * 0.50,
        size.height * 0.28,
      )
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.44,
        size.width * 0.78,
        size.height,
      );
    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.28),
      Offset(size.width * 0.50, size.height),
      Paint()
        ..color = const Color(0xFFF0C9BF)
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CourseMapScenePainter extends CustomPainter {
  final List<CourseMapLesson> lessons;

  const _CourseMapScenePainter(this.lessons);

  @override
  void paint(Canvas canvas, Size size) {
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x55FFEAA3), Color(0x00FFEAA3)],
      ).createShader(
        Rect.fromCircle(center: const Offset(630, 94), radius: 126),
      );
    canvas.drawCircle(const Offset(630, 94), 126, sunPaint);

    final mistPaint = Paint()..color = Colors.white.withOpacity(0.16);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(244, 188),
        width: 330,
        height: 116,
      ),
      mistPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(314, 1038),
        width: 420,
        height: 128,
      ),
      mistPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(574, 84, 90, 326),
        const Radius.circular(44),
      ),
      Paint()..color = const Color(0x4C9FD8EA),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(612, 98, 50, 24),
        const Radius.circular(18),
      ),
      Paint()..color = const Color(0xCC6EA7BA),
    );
    canvas.drawCircle(
      const Offset(620, 190),
      24,
      Paint()..color = const Color(0x5A7AD4D3),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(604, 212, 34, 138),
        const Radius.circular(22),
      ),
      Paint()..color = const Color(0x66DE9B92),
    );

    final lessonPoints = lessons
        .map((lesson) => Offset((size.width * lesson.xAlign) + 8, lesson.top + 88))
        .toList();

    _drawBridge(canvas, lessonPoints[0], lessonPoints[1], beamColor: const Color(0x55F6E1AF));
    _drawLadder(canvas, const Offset(208, 256), const Offset(514, 430));
    _drawBridge(canvas, lessonPoints[1], lessonPoints[2], beamColor: const Color(0x40D8C5F2));
    _drawStairRibbon(canvas, const Offset(524, 508), const Offset(364, 728));
    _drawBridge(canvas, lessonPoints[2], lessonPoints[3], beamColor: const Color(0x40C8D7FF));
    _drawBridge(canvas, lessonPoints[2], lessonPoints[4], beamColor: const Color(0x34FFD7CE));
    _drawBridge(canvas, lessonPoints[3], lessonPoints[5], beamColor: const Color(0x30E2D8FF));

    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(36, 132, 176, 84),
      top: const Color(0xFFF8E7DA),
      front: const Color(0xFFF4CFBC),
      side: const Color(0xFFF09479),
    );
    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(448, 462, 168, 88),
      top: const Color(0xFFFFF4D3),
      front: const Color(0xFFF4DF8E),
      side: const Color(0xFFECCB50),
    );
    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(238, 726, 176, 96),
      top: const Color(0xFFF8EAD7),
      front: const Color(0xFFE0D5F2),
      side: const Color(0xFFBCAFE0),
    );
    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(122, 978, 168, 92),
      top: const Color(0xFFF7E8D8),
      front: const Color(0xFFD8D0EE),
      side: const Color(0xFFBAB2DB),
    );
    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(486, 1168, 162, 92),
      top: const Color(0xFFF9E8D8),
      front: const Color(0xFFF0D2CF),
      side: const Color(0xFFD78882),
    );
    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(42, 1368, 174, 96),
      top: const Color(0xFFF5E7D8),
      front: const Color(0xFFD8D1E8),
      side: const Color(0xFFBEB6D7),
    );

    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.52)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    _drawSparkle(canvas, const Offset(676, 276), sparklePaint);
    _drawSparkle(canvas, const Offset(114, 692), sparklePaint);
    _drawSparkle(canvas, const Offset(564, 1008), sparklePaint);
  }

  void _drawBridge(Canvas canvas, Offset start, Offset end, {required Color beamColor}) {
    final beam = Paint()
      ..color = beamColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;
    final line = Paint()
      ..color = const Color(0xFFF1E6CC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, beam);
    canvas.drawLine(start, end, line);
  }

  void _drawLadder(Canvas canvas, Offset start, Offset end) {
    final rail = Paint()
      ..color = const Color(0xFFECDCB1)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, rail);
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    for (var i = 0; i < 6; i++) {
      final t = i / 5;
      final px = start.dx + (dx * t);
      final py = start.dy + (dy * t);
      canvas.drawLine(
        Offset(px - 12, py - 8),
        Offset(px + 2, py + 8),
        Paint()
          ..color = const Color(0xFFF5EED8)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawStairRibbon(Canvas canvas, Offset start, Offset end) {
    final beam = Paint()
      ..color = const Color(0x40D7C8F0)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, beam);
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    for (var i = 0; i < 11; i++) {
      final t = i / 10;
      final px = start.dx + (dx * t);
      final py = start.dy + (dy * t);
      canvas.drawLine(
        Offset(px - 16, py + 6),
        Offset(px + 12, py - 6),
        Paint()
          ..color = const Color(0xFFF0E6C9)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawPlatform(
    Canvas canvas, {
    required Rect rect,
    required Color top,
    required Color front,
    required Color side,
  }) {
    const skew = 28.0;
    final topFace = Path()
      ..moveTo(rect.left + skew, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right - skew, rect.top + rect.height * 0.26)
      ..lineTo(rect.left, rect.top + rect.height * 0.26)
      ..close();
    final frontFace = Path()
      ..moveTo(rect.left, rect.top + rect.height * 0.26)
      ..lineTo(rect.right - skew, rect.top + rect.height * 0.26)
      ..lineTo(rect.right - skew, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
    final sideFace = Path()
      ..moveTo(rect.right, rect.top)
      ..lineTo(rect.right - skew, rect.top + rect.height * 0.26)
      ..lineTo(rect.right - skew, rect.bottom)
      ..lineTo(rect.right, rect.bottom - rect.height * 0.26)
      ..close();

    canvas.drawShadow(frontFace, const Color(0x182E3557), 14, false);
    canvas.drawPath(topFace, Paint()..color = top);
    canvas.drawPath(frontFace, Paint()..color = front);
    canvas.drawPath(sideFace, Paint()..color = side);
  }

  void _drawStairs(Canvas canvas, Offset start,
      {required double length, required int tilt}) {
    final stairPaint = Paint()
      ..color = const Color(0xFFF7ECDD)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var index = 0; index < 9; index++) {
      final dx = index * (tilt * 5.0);
      final dy = index * 6.0;
      canvas.drawLine(
        Offset(start.dx + dx, start.dy + dy),
        Offset(start.dx + dx + length * 0.18, start.dy + dy),
        stairPaint,
      );
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - 6, center.dy),
      Offset(center.dx + 6, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 6),
      Offset(center.dx, center.dy + 6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CourseMapScenePainter oldDelegate) => false;
}
