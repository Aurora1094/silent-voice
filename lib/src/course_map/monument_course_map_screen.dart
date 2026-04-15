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
    colors: [Color(0xFFFFD2C4), Color(0xFFFFE2D7)],
    lane: 0,
    xAlign: 0.22,
    top: 268,
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
    colors: [Color(0xFFFFE2AE), Color(0xFFFFF0CF)],
    lane: 1,
    xAlign: 0.74,
    top: 416,
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
    colors: [Color(0xFFA9E3D8), Color(0xFFD5F4EE)],
    lane: 2,
    xAlign: 0.82,
    top: 640,
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
    colors: [Color(0xFFD8CCF6), Color(0xFFEDE7FF)],
    lane: 1,
    xAlign: 0.44,
    top: 858,
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
    colors: [Color(0xFFFFD1DA), Color(0xFFFFE7EC)],
    lane: 2,
    xAlign: 0.78,
    top: 1082,
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
    colors: [Color(0xFFCFCAE0), Color(0xFFE7E3F0)],
    lane: 0,
    xAlign: 0.28,
    top: 1298,
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
  static const double _mapWidth = 980;
  static const double _mapHeight = 1560;

  late final TransformationController _transformationController;
  bool _matrixReady = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

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
        if (!_matrixReady && constraints.maxWidth > 0 && constraints.maxHeight > 0) {
          final scale = constraints.maxWidth < 390 ? 0.84 : 0.92;
          final tx = (constraints.maxWidth - (_mapWidth * scale)) / 2;
          final ty = viewPadding.top + 24;
          _transformationController.value = Matrix4.identity()
            ..translate(tx, ty)
            ..scale(scale);
          _matrixReady = true;
        }

        return Stack(
          children: [
            const Positioned.fill(child: _CourseMapBackground()),
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.74,
                maxScale: 2.2,
                constrained: false,
                clipBehavior: Clip.none,
                boundaryMargin: const EdgeInsets.all(260),
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
                        left: 286,
                        top: 176,
                        child: _MainMonumentCluster(),
                      ),
                      const Positioned(
                        left: 86,
                        top: 902,
                        child: _ReflectivePool(),
                      ),
                      const Positioned(
                        right: 96,
                        top: 336,
                        child: _MiniTower(),
                      ),
                      for (final lesson in courseMapLessons)
                        Positioned(
                          left: (_mapWidth * lesson.xAlign) - 38,
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = lesson.current ? 0.68 + (_controller.value * 0.32) : 0.42;
        return GestureDetector(
          onTap: widget.onTap,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(locked ? 0.82 : 0.98),
                          (locked
                                  ? const Color(0xFFD0CBD9)
                                  : lesson.colors.first)
                              .withOpacity(0.96),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.82),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (locked
                                  ? const Color(0xFFBCB6C6)
                                  : lesson.colors.first)
                              .withOpacity(glow),
                          blurRadius: lesson.current ? 30 : 18,
                          spreadRadius: lesson.current ? 4 : 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.82),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E3557).withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          locked ? Icons.lock_outline_rounded : lesson.icon,
                          size: 22,
                          color: locked
                              ? const Color(0xFF8B8795)
                              : const Color(0xFF47516E),
                        ),
                      ),
                    ),
                  ),
                  if (completed)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.92),
                          boxShadow: [
                            BoxShadow(
                              color: lesson.colors.first.withOpacity(0.42),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Color(0xFF3C516C),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                constraints: const BoxConstraints(maxWidth: 102),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withOpacity(0.54),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.64),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lesson.title,
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
                    const SizedBox(height: 2),
                    Text(
                      lesson.stateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: locked
                            ? const Color(0xFF9B96A5)
                            : const Color(0xFF6E7795),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
      width: 394,
      height: 452,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 24,
            top: 208,
            child: _IsoTower(
              width: 92,
              height: 180,
              topColor: const Color(0xFFF7E8D7),
              frontColor: const Color(0xFFECAEA7),
              sideColor: const Color(0xFFD69198),
            ),
          ),
          Positioned(
            right: 18,
            top: 192,
            child: _IsoTower(
              width: 74,
              height: 176,
              topColor: const Color(0xFFF7E8D8),
              frontColor: const Color(0xFFE9A8A3),
              sideColor: const Color(0xFFD38792),
            ),
          ),
          Positioned(
            left: 108,
            top: 50,
            child: _IsoTower(
              width: 168,
              height: 286,
              topColor: const Color(0xFFF8E7D7),
              frontColor: const Color(0xFFD8D1F0),
              sideColor: const Color(0xFFBBB2DB),
              title: 'SILENT\nVOICE',
            ),
          ),
          Positioned(
            left: 70,
            right: 58,
            bottom: 18,
            child: Container(
              height: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8E8D8), Color(0xFFE5C5C2)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E3557).withOpacity(0.08),
                    blurRadius: 22,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 154,
            top: 192,
            child: SizedBox(
              width: 86,
              height: 102,
              child: CustomPaint(
                painter: _ArchPainter(),
              ),
            ),
          ),
          Positioned(
            left: 194,
            top: 314,
            child: Container(
              width: 28,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF8E93B0).withOpacity(0.56),
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
      width: 120,
      height: 160,
      child: Stack(
        children: [
          Positioned(
            left: 24,
            top: 32,
            child: _IsoTower(
              width: 52,
              height: 110,
              topColor: const Color(0xFFF7E7D5),
              frontColor: const Color(0xFFE8A39F),
              sideColor: const Color(0xFFD48792),
            ),
          ),
          Positioned(
            left: 44,
            top: 6,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.70),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: Color(0xFF4A5572),
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
      width: 144,
      height: 156,
      child: Stack(
        children: [
          Positioned(
            left: 30,
            top: 46,
            child: _IsoTower(
              width: 46,
              height: 86,
              topColor: const Color(0xFFF8E8D8),
              frontColor: const Color(0xFFE5C8D1),
              sideColor: const Color(0xFFD6CBE9),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF8FE4EF).withOpacity(0.65),
                    const Color(0xFFE8F7FB).withOpacity(0.78),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8FE4EF).withOpacity(0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
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
    final mistPaint = Paint()..color = Colors.white.withOpacity(0.14);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.30, 236),
        width: 280,
        height: 86,
      ),
      mistPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.76, 1040),
        width: 360,
        height: 94,
      ),
      mistPaint,
    );

    final pathShadow = Paint()
      ..color = const Color(0x122E3557)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 24;
    final pathPaint = Paint()
      ..color = const Color(0xFFF8E8D8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    final lessonPoints = lessons
        .map((lesson) => Offset((size.width * lesson.xAlign), lesson.top + 38))
        .toList();
    final route = Path()..moveTo(lessonPoints.first.dx, lessonPoints.first.dy);
    for (var index = 1; index < lessonPoints.length; index++) {
      final previous = lessonPoints[index - 1];
      final current = lessonPoints[index];
      route.cubicTo(
        (previous.dx + current.dx) / 2,
        previous.dy - 26,
        (previous.dx + current.dx) / 2,
        current.dy + 26,
        current.dx,
        current.dy,
      );
    }

    canvas.drawPath(route, pathShadow);
    canvas.drawPath(route, pathPaint);

    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(108, 232, 210, 98),
      top: const Color(0xFFF7E5D5),
      front: const Color(0xFFE6B8BC),
      side: const Color(0xFFD4C8EA),
    );
    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(620, 376, 218, 100),
      top: const Color(0xFFF7E8D8),
      front: const Color(0xFFD8D0EF),
      side: const Color(0xFFB8AFD8),
    );
    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(704, 612, 188, 96),
      top: const Color(0xFFF7E6D6),
      front: const Color(0xFFEAB0A6),
      side: const Color(0xFFD88E96),
    );
    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(300, 834, 240, 106),
      top: const Color(0xFFF7E6D7),
      front: const Color(0xFFD8D0EE),
      side: const Color(0xFFBAB2DB),
    );
    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(648, 1056, 228, 102),
      top: const Color(0xFFF8E7D7),
      front: const Color(0xFFE7B2B3),
      side: const Color(0xFFD5C8EA),
    );
    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(122, 1280, 250, 110),
      top: const Color(0xFFF8E8D8),
      front: const Color(0xFFD8D1E8),
      side: const Color(0xFFBEB6D7),
    );

    _drawStairs(canvas, const Offset(642, 330), length: 104, tilt: 1);
    _drawStairs(canvas, const Offset(776, 542), length: 112, tilt: 1);
    _drawStairs(canvas, const Offset(132, 980), length: 102, tilt: -1);
    _drawStairs(canvas, const Offset(684, 1184), length: 110, tilt: -1);

    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.52)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    _drawSparkle(canvas, const Offset(874, 1324), sparklePaint);
    _drawSparkle(canvas, const Offset(94, 748), sparklePaint);
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
