import 'dart:async';
import 'dart:math' as math;
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
  final List<Color> colors;
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
    required this.colors,
    required this.xAlign,
    required this.top,
    required this.state,
  });

  bool get locked => state == CourseMapLessonState.locked;
  bool get current => state == CourseMapLessonState.current;
  bool get completed => state == CourseMapLessonState.completed;

  CourseMapLesson copyWith({
    String? chapter,
    String? title,
    String? subtitle,
    String? duration,
    String? description,
    IconData? icon,
    String? progressLabel,
    String? difficulty,
    double? progressValue,
    List<Color>? colors,
    double? xAlign,
    double? top,
    CourseMapLessonState? state,
  }) {
    return CourseMapLesson(
      chapter: chapter ?? this.chapter,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      progressLabel: progressLabel ?? this.progressLabel,
      difficulty: difficulty ?? this.difficulty,
      progressValue: progressValue ?? this.progressValue,
      colors: colors ?? this.colors,
      xAlign: xAlign ?? this.xAlign,
      top: top ?? this.top,
      state: state ?? this.state,
    );
  }

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
    title: '我',
    subtitle: '自我指向',
    duration: '06 min',
    description: '从指向自身的动作开始，建立最基础的人称表达。',
    icon: Icons.person_rounded,
    progressLabel: '起始课程',
    difficulty: '入门',
    progressValue: 1,
    colors: [Color(0xFF8CD6C2), Color(0xFFD8F4E9)],
    xAlign: 0.16,
    top: 148,
    state: CourseMapLessonState.current,
  ),
  CourseMapLesson(
    chapter: '第一章',
    title: '爱',
    subtitle: '情感表达',
    duration: '08 min',
    description: '把胸前动作和情绪感受联系起来，让表达更自然。',
    icon: Icons.favorite_outline_rounded,
    progressLabel: '发音与节奏',
    difficulty: '入门',
    progressValue: 1,
    colors: [Color(0xFFF7C9CB), Color(0xFFFFE6E8)],
    xAlign: 0.70,
    top: 358,
    state: CourseMapLessonState.upcoming,
  ),
  CourseMapLesson(
    chapter: '第一章',
    title: '南',
    subtitle: '方向方位',
    duration: '07 min',
    description: '练习方向类手势的落点和转向，建立空间感知。',
    icon: Icons.explore_rounded,
    progressLabel: '当前学习',
    difficulty: '基础',
    progressValue: 0.62,
    colors: [Color(0xFFCFE5FF), Color(0xFFEAF4FF)],
    xAlign: 0.46,
    top: 760,
    state: CourseMapLessonState.upcoming,
  ),
  CourseMapLesson(
    chapter: '第一章',
    title: '开',
    subtitle: '动作展开',
    duration: '09 min',
    description: '练习张开的轨迹和停顿，让手势结构更清晰完整。',
    icon: Icons.pan_tool_alt_rounded,
    progressLabel: '下一节',
    difficulty: '基础',
    progressValue: 0.12,
    colors: [Color(0xFFF7D4AE), Color(0xFFFFEBD9)],
    xAlign: 0.30,
    top: 1030,
    state: CourseMapLessonState.upcoming,
  ),
  CourseMapLesson(
    chapter: '第一章',
    title: '你好',
    subtitle: '基础问候',
    duration: '07 min',
    description: '回到常用问候动作，练习节奏和起手位置的稳定性。',
    icon: Icons.front_hand_rounded,
    progressLabel: '可直接学习',
    difficulty: '进阶',
    progressValue: 0.04,
    colors: [Color(0xFFF7C7B6), Color(0xFFFFE8DB)],
    xAlign: 0.73,
    top: 1260,
    state: CourseMapLessonState.upcoming,
  ),
  CourseMapLesson(
    chapter: '第一章',
    title: '谢谢',
    subtitle: '礼貌回应',
    duration: '09 min',
    description: '练习从下巴前方送出的轨迹，让感谢表达更稳定柔和。',
    icon: Icons.favorite_outline_rounded,
    progressLabel: '可直接学习',
    difficulty: '进阶',
    progressValue: 0.03,
    colors: [Color(0xFFF5D770), Color(0xFFFFF2C9)],
    xAlign: 0.18,
    top: 1568,
    state: CourseMapLessonState.upcoming,
  ),
  CourseMapLesson(
    chapter: '第一章',
    title: '没有',
    subtitle: '缺失表达',
    duration: '06 min',
    description: '把否定延展成更完整的语义，让动作表达更加明确。',
    icon: Icons.block_rounded,
    progressLabel: '可直接学习',
    difficulty: '基础',
    progressValue: 0.03,
    colors: [Color(0xFFE5C8EC), Color(0xFFF4E4F8)],
    xAlign: 0.40,
    top: 1818,
    state: CourseMapLessonState.upcoming,
  ),
];

class MonumentCourseMapScreen extends StatefulWidget {
  final List<CourseMapLesson> lessons;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<int> onStartLesson;

  const MonumentCourseMapScreen({
    super.key,
    required this.lessons,
    required this.onTabChanged,
    required this.onStartLesson,
  });

  @override
  State<MonumentCourseMapScreen> createState() =>
      _MonumentCourseMapScreenState();
}

class _MonumentCourseMapScreenState extends State<MonumentCourseMapScreen>
    with SingleTickerProviderStateMixin {
  static const double _mapWidth = 760;
  static const double _mapHeight = 2840;
  static const Duration _collapseDelay = Duration(milliseconds: 70);

  late final AnimationController _floatController;
  Timer? _collapseTimer;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseMapLessons = widget.lessons;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final completedCount =
        widget.lessons.where((lesson) => lesson.completed).length;
    final currentLesson = widget.lessons.firstWhere(
      (lesson) => lesson.current,
      orElse: () => widget.lessons.lastWhere(
        (lesson) => !lesson.locked,
        orElse: () => widget.lessons.first,
      ),
    );
    final selectedLesson =
        _selectedIndex == null ? null : widget.lessons[_selectedIndex!];

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapScale = constraints.maxWidth / _mapWidth;
        final scaledMapHeight = _mapHeight * mapScale;
        final headerInset = viewPadding.top + 156;
        final navInset = viewPadding.bottom + 94;
        final cardInset = navInset + (selectedLesson == null ? 12.0 : 154.0);

        return Stack(
          children: [
            const Positioned.fill(child: _CourseMapAtmosphere()),
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (_selectedIndex != null &&
                      (notification is ScrollStartNotification ||
                          notification is ScrollUpdateNotification ||
                          notification is UserScrollNotification)) {
                    _scheduleCollapseCard();
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: headerInset,
                    bottom: cardInset,
                  ),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: scaledMapHeight,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                      child: AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          final drift =
                              math.sin(_floatController.value * math.pi * 2) * 5;
                          return SizedBox(
                            width: _mapWidth,
                            height: _mapHeight,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _CourseScenePainter(
                                      lessons: widget.lessons,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 164,
                                  top: 204 + drift * 0.50,
                                  child: const Opacity(
                                    opacity: 0.84,
                                    child: _CentralMonument(),
                                  ),
                                ),
                                Positioned(
                                  left: -8,
                                  top: 126 + drift * 0.16,
                                  child: const Opacity(
                                    opacity: 0.48,
                                    child: _GlassAlcove(),
                                  ),
                                ),
                                Positioned(
                                  right: -8,
                                  top: 130 + drift * 0.18,
                                  child: const Opacity(
                                    opacity: 0.46,
                                    child: _SideCapsuleCluster(),
                                  ),
                                ),
                                Positioned(
                                  left: 18,
                                  top: 1206 + drift * 0.08,
                                  child: const Opacity(
                                    opacity: 0.52,
                                    child: _WaterPillar(),
                                  ),
                                ),
                                if (widget.lessons.length > 6)
                                  Positioned(
                                    right: 24,
                                    top: 1728 + drift * 0.08,
                                    child: const Opacity(
                                      opacity: 0.34,
                                      child: _SideCapsuleCluster(),
                                    ),
                                  ),
                                if (widget.lessons.length > 7)
                                  Positioned(
                                    left: -6,
                                    top: 2154 + drift * 0.06,
                                    child: const Opacity(
                                      opacity: 0.30,
                                      child: _GlassAlcove(),
                                    ),
                                  ),
                                if (widget.lessons.length > 8)
                                  Positioned(
                                    right: 112,
                                    top: 2452 + drift * 0.05,
                                    child: const Opacity(
                                      opacity: 0.40,
                                      child: _WaterPillar(),
                                    ),
                                  ),
                                const Positioned.fill(
                                  child: CustomPaint(
                                    painter: _PrimaryBridgeOverlayPainter(),
                                  ),
                                ),
                                for (var i = 0; i < widget.lessons.length; i++)
                                  Positioned(
                                    left: (_mapWidth * widget.lessons[i].xAlign) - 68,
                                    top: widget.lessons[i].top,
                                    child: _CourseMapNode(
                                    lesson: widget.lessons[i],
                                    selected: _selectedIndex == i,
                                    onTap: () {
                                      _cancelCollapseCard();
                                      setState(() {
                                        _selectedIndex = i;
                                      });
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
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
                    text: '第一章 · 课程地图',
                  ),
                  const Spacer(),
                  _GlassPill(
                    icon: Icons.layers_outlined,
                    text: '旅程进度 $completedCount/${courseMapLessons.length}',
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: viewPadding.top + 64,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _CourseSummaryHeader(
                    currentLesson: currentLesson,
                    completedCount: completedCount,
                    totalCount: courseMapLessons.length,
                  ),
                  Positioned(
                    right: 14,
                    top: -12,
                    child: _ChapterHaloBadge(
                      lesson: currentLesson,
                      completedCount: completedCount,
                      totalCount: courseMapLessons.length,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: navInset,
              child: ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOutCubicEmphasized,
                  alignment: Alignment.bottomCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    reverseDuration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.22),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                          reverseCurve: Curves.easeInCubic,
                        ),
                      );
                      final scale = Tween<double>(
                        begin: 0.96,
                        end: 1,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                          reverseCurve: Curves.easeInCubic,
                        ),
                      );

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: slide,
                          child: ScaleTransition(
                            scale: scale,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: selectedLesson == null
                        ? const SizedBox(
                            key: ValueKey('collapsed-course-card'),
                            height: 0,
                          )
                        : TapRegion(
                            key: ValueKey(selectedLesson.title),
                            onTapOutside: (_) => _dismissCard(),
                            child: _CourseInfoCard(
                              lesson: selectedLesson,
                              onStartTap: selectedLesson.locked
                                  ? null
                                  : () {
                                      final selectedIndex = _selectedIndex;
                                      if (selectedIndex == null) return;
                                      _openLearningDialog(
                                        selectedIndex,
                                        selectedLesson,
                                      );
                                    },
                            ),
                          ),
                  ),
                ),
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

  void _scheduleCollapseCard() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(_collapseDelay, () {
      if (!mounted || _selectedIndex == null) return;
      _dismissCard();
    });
  }

  void _cancelCollapseCard() {
    _collapseTimer?.cancel();
    _collapseTimer = null;
  }

  void _dismissCard() {
    _cancelCollapseCard();
    if (!mounted || _selectedIndex == null) return;
    setState(() {
      _selectedIndex = null;
    });
  }

  Future<void> _openLearningDialog(int index, CourseMapLesson lesson) async {
    widget.onStartLesson(index);
    _dismissCard();
    if (!mounted) return;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'lesson-learning-dialog',
      barrierColor: Colors.black.withOpacity(0.20),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: _LearningDialogShell(lesson: lesson),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.96,
                end: 1,
              ).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _LearningDialogShell extends StatelessWidget {
  final CourseMapLesson lesson;

  const _LearningDialogShell({
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 440,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.84),
                  lesson.colors.last.withOpacity(0.54),
                  lesson.colors.first.withOpacity(0.24),
                ],
              ),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: Colors.white.withOpacity(0.82),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E3557).withOpacity(0.14),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: lesson.colors.first.withOpacity(0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withOpacity(0.76),
                      ),
                      child: const Text(
                        '开始学习',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5B6684),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.68),
                        foregroundColor: const Color(0xFF53607D),
                      ),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C3553),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${lesson.chapter} · ${lesson.subtitle}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667290),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        lesson.colors.last.withOpacity(0.82),
                        lesson.colors.first.withOpacity(0.48),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.74),
                        ),
                        child: Icon(
                          lesson.icon,
                          size: 30,
                          color: const Color(0xFF52607B),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '浮窗主体已预留',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF32405C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '这里先作为课程“${lesson.title}”的学习浮窗页面，后续你告诉我需要放哪些内容，我再继续填进去。',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.55,
                          color: const Color(0xFF53627E).withOpacity(0.94),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _LearningDialogMetric(
                        label: '课程',
                        value: lesson.title,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _LearningDialogMetric(
                        label: '状态',
                        value: lesson.stateLabel,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _LearningDialogMetric(
                        label: '时长',
                        value: lesson.duration,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2F3A59),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text('关闭浮窗'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LearningDialogMetric extends StatelessWidget {
  final String label;
  final String value;

  const _LearningDialogMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.56),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7B86A1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF31405C),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseMapAtmosphere extends StatelessWidget {
  const _CourseMapAtmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: const [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x30FFF7EA),
                    Color(0x0AFFFFFF),
                    Color(0x12EDE7FF),
                    Color(0x1ADFF1FF),
                  ],
                  stops: [0.0, 0.26, 0.62, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: -122,
            left: -94,
            child: _AtmosphereBlob(
              size: 286,
              colors: [Color(0xFFFFEFC3), Color(0xFFFFD6C7)],
              opacity: 0.34,
            ),
          ),
          Positioned(
            top: 142,
            right: -58,
            child: _AtmosphereBlob(
              size: 246,
              colors: [Color(0xFFD6E6FF), Color(0xFFEFE7FF)],
              opacity: 0.26,
            ),
          ),
          Positioned(
            bottom: 138,
            left: -42,
            child: _AtmosphereBlob(
              size: 228,
              colors: [Color(0xFFFFE2D4), Color(0xFFF6E8FF)],
              opacity: 0.22,
            ),
          ),
          Positioned(
            top: 104,
            left: 30,
            child: _AtmosphereBeam(
              width: 84,
              height: 186,
              colors: [Color(0x6EFFFFFF), Color(0x16FFFFFF)],
            ),
          ),
          Positioned(
            bottom: 112,
            right: 30,
            child: _AtmosphereBeam(
              width: 96,
              height: 248,
              colors: [Color(0x56D8EDFF), Color(0x12FFFFFF)],
            ),
          ),
        ],
      ),
    );
  }
}

class _AtmosphereBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final double opacity;

  const _AtmosphereBlob({
    required this.size,
    required this.colors,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            colors.first.withOpacity(opacity),
            colors.last.withOpacity(opacity * 0.72),
            colors.last.withOpacity(0),
          ],
          stops: const [0.0, 0.54, 1.0],
        ),
      ),
    );
  }
}

class _AtmosphereBeam extends StatelessWidget {
  final double width;
  final double height;
  final List<Color> colors;

  const _AtmosphereBeam({
    required this.width,
    required this.height,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.52),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.18),
            blurRadius: 26,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _ChapterHaloBadge extends StatelessWidget {
  final CourseMapLesson lesson;
  final int completedCount;
  final int totalCount;

  const _ChapterHaloBadge({
    required this.lesson,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.90),
            lesson.colors.last.withOpacity(0.86),
            lesson.colors.first.withOpacity(0.82),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: lesson.colors.first.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            lesson.icon,
            size: 20,
            color: const Color(0xFF505A77),
          ),
          const SizedBox(height: 4),
          Text(
            '$completedCount/$totalCount',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E3557),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseSummaryHeader extends StatelessWidget {
  final CourseMapLesson currentLesson;
  final int completedCount;
  final int totalCount;

  const _CourseSummaryHeader({
    required this.currentLesson,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;
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

class _CourseInfoCard extends StatelessWidget {
  final CourseMapLesson lesson;
  final VoidCallback? onStartTap;

  const _CourseInfoCard({
    required this.lesson,
    required this.onStartTap,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColors = lesson.locked
        ? const [Color(0xFFE0DCE8), Color(0xFFD1CBDC)]
        : lesson.colors;
    final accentShadow = lesson.locked
        ? const Color(0xFFCFC9D8)
        : lesson.colors.first;
    final cardGlow = lesson.colors.first.withOpacity(0.16);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey(lesson.title),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.76),
                  lesson.colors.last.withOpacity(0.30),
                  lesson.colors.first.withOpacity(0.18),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.78),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF323954).withOpacity(0.07),
                  blurRadius: 36,
                  spreadRadius: 1,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: cardGlow,
                  blurRadius: 28,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
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
                        size: 24,
                        color: const Color(0xFF4B5574),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${lesson.chapter} · ${lesson.subtitle}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6A7591),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            lesson.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF28324E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      lesson.stateLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: lesson.locked
                            ? const Color(0xFF8B8795)
                            : const Color(0xFF5C6783),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        lesson.colors.first.withOpacity(0.20),
                        lesson.colors.last.withOpacity(0.42),
                        Colors.white.withOpacity(0.48),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.62),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '课程氛围',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF6A7591).withOpacity(0.92),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${lesson.chapter} · ${lesson.subtitle}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF313A59),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              lesson.colors.last.withOpacity(0.94),
                              lesson.colors.first.withOpacity(0.94),
                            ],
                          ),
                        ),
                        child: Icon(
                          lesson.icon,
                          color: const Color(0xFF46516D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  lesson.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: Color(0xFF66708D),
                  ),
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 14),
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: buttonColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: buttonColors.first.withOpacity(0.24),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: onStartTap,
                      child: Center(
                        child: Text(
                          lesson.locked
                              ? '完成前置课程后解锁'
                              : lesson.state == CourseMapLessonState.completed
                                  ? '设为复习课程'
                                  : '开始学习',
                          style: TextStyle(
                            fontSize: 15,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.54),
                const Color(0xFFF8F1FF).withOpacity(0.34),
                const Color(0xFFEAF6FF).withOpacity(0.28),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withOpacity(0.68),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E3557).withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.74),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: const Color(0xFF4D5776),
                ),
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

class _CourseMapNode extends StatefulWidget {
  final CourseMapLesson lesson;
  final bool selected;
  final VoidCallback onTap;

  const _CourseMapNode({
    required this.lesson,
    required this.selected,
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
    final selected = widget.selected;
    final locked = lesson.locked;
    final completed = lesson.state == CourseMapLessonState.completed;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final breath = lesson.current ? 0.72 + (_controller.value * 0.28) : 0.40;
        return AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          scale: selected ? 1.03 : 1,
          child: GestureDetector(
            onTap: widget.onTap,
            child: SizedBox(
              width: 148,
              child: Column(
                children: [
                  SizedBox(
                    width: 148,
                    height: 148,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          bottom: 16,
                          child: CustomPaint(
                            size: const Size(128, 88),
                            painter: _NodePedestalPainter(
                              topColor: locked
                                  ? const Color(0xFFE9E4EF)
                                  : lesson.colors.last,
                              frontColor: locked
                                  ? const Color(0xFFD6D0DD)
                                  : lesson.colors.first.withOpacity(
                                      selected ? 0.94 : 0.84,
                                    ),
                              sideColor: locked
                                  ? const Color(0xFFC0BAC8)
                                  : _nodeSideColor(lesson).withOpacity(
                                      selected ? 0.92 : 0.76,
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: lesson.current ? 10 : 8,
                          child: _NodeTotem(
                            lesson: lesson,
                            glow: breath + (selected ? 0.18 : 0),
                          ),
                        ),
                        if (selected)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: lesson.colors.first.withOpacity(0.13),
                                      blurRadius: 22,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (completed)
                          Positioned(
                            right: 10,
                            top: 20,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFE184).withOpacity(0.94),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color(0xFFFFE184).withOpacity(0.44),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Color(0xFF6B5B37),
                              ),
                            ),
                          ),
                        if (lesson.current)
                          Positioned(
                            right: 10,
                            bottom: 20,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFC8AF).withOpacity(0.98),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color(0xFFFFC8AF).withOpacity(0.34),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 20,
                                color: Color(0xFF7E5E57),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _nodeSideColor(CourseMapLesson lesson) {
    if (lesson.title == '我') return const Color(0xFF83D2C7);
    if (lesson.title == '爱') return const Color(0xFFD88B8C);
    if (lesson.title == '南') return const Color(0xFF8FB5E8);
    if (lesson.title == '开') return const Color(0xFFF0B27D);
    if (lesson.title == '你好') return const Color(0xFFE39B88);
    if (lesson.title == '谢谢') return const Color(0xFFE9C852);
    if (lesson.title == '没有') return const Color(0xFFD2A3D8);
    return const Color(0xFFF09B84);
  }
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF2D8), Color(0xFFF6C7A8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD7B6).withOpacity(0.52),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 38,
            height: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lesson.colors.last.withOpacity(0.98),
                  lesson.colors.first.withOpacity(0.98),
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
                width: 12,
                height: 33,
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
      width: 36,
      height: 92,
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
          Container(
            width: 12,
            height: 34,
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

class _CentralMonument extends StatelessWidget {
  const _CentralMonument();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 410,
      height: 710,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 124,
            top: 170,
            child: Container(
              width: 154,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.94),
                    const Color(0xFFFFF1D2).withOpacity(0.86),
                    const Color(0xFFF2D8BA).withOpacity(0.72),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFE7A0).withOpacity(0.28),
                    blurRadius: 30,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(44),
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.2),
                          radius: 0.9,
                          colors: [
                            Colors.white.withOpacity(0.24),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'SILENT\nVOICE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.02,
                        fontSize: 23,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: -34,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 40,
                          color: Color(0xFFF7D54C),
                        ),
                        Container(
                          width: 22,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFF4CB), Color(0xFFF5D870)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 42,
            top: 232,
            child: Container(
              width: 24,
              height: 246,
              decoration: BoxDecoration(
                color: const Color(0xFFE79296).withOpacity(0.72),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Positioned(
            right: 48,
            top: 240,
            child: Container(
              width: 24,
              height: 232,
              decoration: BoxDecoration(
                color: const Color(0xFFE4A49B).withOpacity(0.72),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Positioned(
            left: 86,
            right: 86,
            bottom: 168,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF7E3D3), Color(0xFFEFD1C2)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassAlcove extends StatelessWidget {
  const _GlassAlcove();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 320,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 68,
            child: Container(
              width: 130,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),
                border: Border.all(
                  color: Colors.white.withOpacity(0.28),
                  width: 4,
                ),
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 0,
            child: SizedBox(
              width: 122,
              height: 104,
              child: CustomPaint(
                painter: _NodePedestalPainter(
                  topColor: const Color(0xFFFCE5D8),
                  frontColor: const Color(0xFFF5D2C4),
                  sideColor: const Color(0xFFF09B84),
                ),
              ),
            ),
          ),
          Positioned(
            left: 74,
            top: 10,
            child: Container(
              width: 24,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFFF09B84),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideCapsuleCluster extends StatelessWidget {
  const _SideCapsuleCluster();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 354,
      child: Stack(
        children: [
          Positioned(
            right: 18,
            top: 0,
            child: Container(
              width: 82,
              height: 236,
              decoration: BoxDecoration(
                color: const Color(0xFF9BD7EA).withOpacity(0.54),
                borderRadius: BorderRadius.circular(44),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: 18,
            child: Container(
              width: 56,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFF6EA7BA).withOpacity(0.92),
              ),
            ),
          ),
          Positioned(
            right: 64,
            top: 98,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF79D4D2).withOpacity(0.54),
              ),
            ),
          ),
          Positioned(
            right: 68,
            top: 146,
            child: Container(
              width: 36,
              height: 122,
              decoration: BoxDecoration(
                color: const Color(0xFFE09C92).withOpacity(0.58),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 226,
            child: SizedBox(
              width: 116,
              height: 78,
              child: CustomPaint(
                painter: _NodePedestalPainter(
                  topColor: const Color(0xFFFCE4D8),
                  frontColor: const Color(0xFFF1D1C7),
                  sideColor: const Color(0xFFD78882),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterPillar extends StatelessWidget {
  const _WaterPillar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 170,
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 24,
            child: Container(
              width: 48,
              height: 118,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF8EDFF0).withOpacity(0.92),
                    const Color(0xFF86BFFF).withOpacity(0.82),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 26,
            top: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.62),
              ),
            ),
          ),
        ],
      ),
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
    final topFaceHeight = size.height * 0.30;
    final baseBottom = size.height;
    final topFace = Path()
      ..moveTo(skew, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - skew, topFaceHeight)
      ..lineTo(0, topFaceHeight)
      ..close();
    final frontFace = Path()
      ..moveTo(0, topFaceHeight)
      ..lineTo(size.width - skew, topFaceHeight)
      ..lineTo(size.width - skew, baseBottom)
      ..lineTo(0, baseBottom)
      ..close();
    final sideFace = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width - skew, topFaceHeight)
      ..lineTo(size.width - skew, baseBottom)
      ..lineTo(size.width, size.height * 0.72)
      ..close();

    canvas.drawShadow(frontFace, const Color(0x162E3557), 12, false);
    canvas.drawPath(topFace, Paint()..color = topColor);
    canvas.drawPath(frontFace, Paint()..color = frontColor);
    canvas.drawPath(sideFace, Paint()..color = sideColor);
    canvas.drawLine(
      Offset(skew + 10, 8),
      Offset(size.width - 18, 8),
      Paint()
        ..color = Colors.white.withOpacity(0.46)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _NodePedestalPainter oldDelegate) {
    return oldDelegate.topColor != topColor ||
        oldDelegate.frontColor != frontColor ||
        oldDelegate.sideColor != sideColor;
  }
}

class _CourseScenePainter extends CustomPainter {
  final List<CourseMapLesson> lessons;

  const _CourseScenePainter({
    required this.lessons,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawSunGlow(canvas);
    _drawMist(canvas);
    _drawParticles(canvas);

    final anchors = lessons
        .map((lesson) => Offset(size.width * lesson.xAlign, lesson.top + 84))
        .toList();

    if (anchors.length > 3) {
      _drawRope(canvas, anchors[2], anchors[3]);
    }
    if (anchors.length > 4) {
      _drawRope(canvas, anchors[2], anchors[4]);
    }
    if (anchors.length > 5) {
      _drawRope(canvas, anchors[3], anchors[5]);
    }
    if (anchors.length > 6) {
      _drawRope(canvas, anchors[5], anchors[6]);
    }
    if (anchors.length > 7) {
      _drawRope(canvas, anchors[6], anchors[7]);
    }
    if (anchors.length > 8) {
      _drawRope(canvas, anchors[7], anchors[8]);
    }
    if (anchors.length > 9) {
      _drawRope(canvas, anchors[8], anchors[9]);
    }

    _drawGhostArch(
      canvas,
      rect: const Rect.fromLTWH(18, 208, 152, 266),
      opacity: 0.08,
      angle: -0.18,
    );
    _drawSupportCapsule(
      canvas,
      rect: const Rect.fromLTWH(608, 84, 94, 246),
      color: const Color(0xFF9BD7EA),
      opacity: 0.14,
    );
    _drawSupportCapsule(
      canvas,
      rect: const Rect.fromLTWH(582, 1130, 86, 238),
      color: const Color(0xFFF1C8C3),
      opacity: 0.11,
    );

    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(346, 620, 112, 56),
      top: const Color(0xFFF9E8D8),
      front: const Color(0xFFE7DDF3),
      side: const Color(0xFFB9AEDC),
    );
    _drawPlatform(
      canvas,
      rect: const Rect.fromLTWH(308, 1366, 122, 60),
      top: const Color(0xFFF6EAD9),
      front: const Color(0xFFE1D7EF),
      side: const Color(0xFFBBAFDA),
    );
    if (lessons.length > 6) {
      _drawGhostArch(
        canvas,
        rect: const Rect.fromLTWH(74, 1758, 150, 258),
        opacity: 0.06,
        angle: 0.12,
      );
      _drawSupportCapsule(
        canvas,
        rect: const Rect.fromLTWH(596, 1846, 88, 232),
        color: const Color(0xFF9BCBE7),
        opacity: 0.12,
      );
      _drawSupportCapsule(
        canvas,
        rect: const Rect.fromLTWH(72, 2228, 82, 220),
        color: const Color(0xFFF1C8BF),
        opacity: 0.10,
      );
      _drawPlatform(
        canvas,
        rect: const Rect.fromLTWH(394, 1702, 118, 58),
        top: const Color(0xFFF7ECDD),
        front: const Color(0xFFDCE5F4),
        side: const Color(0xFFAFC1DA),
      );
      _drawPlatform(
        canvas,
        rect: const Rect.fromLTWH(208, 2432, 126, 60),
        top: const Color(0xFFF7EAD9),
        front: const Color(0xFFE8D8EE),
        side: const Color(0xFFC9B2D9),
      );
    }

    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.42)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    _drawSparkle(canvas, const Offset(628, 310), sparklePaint);
    _drawSparkle(canvas, const Offset(632, 1432), sparklePaint);
    if (lessons.length > 6) {
      _drawSparkle(canvas, const Offset(612, 1892), sparklePaint);
      _drawSparkle(canvas, const Offset(170, 2468), sparklePaint);
    }
  }

  void _drawSunGlow(Canvas canvas) {
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x52FFE7A0), Color(0x00FFE7A0)],
      ).createShader(
        Rect.fromCircle(center: const Offset(624, 124), radius: 132),
      );
    canvas.drawCircle(const Offset(624, 124), 132, sunPaint);
  }

  void _drawMist(Canvas canvas) {
    final mist = Paint()..color = Colors.white.withOpacity(0.10);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(290, 346),
        width: 360,
        height: 100,
      ),
      mist,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(510, 922),
        width: 380,
        height: 108,
      ),
      mist,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(292, 1816),
        width: 352,
        height: 96,
      ),
      mist,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(480, 2302),
        width: 390,
        height: 114,
      ),
      mist,
    );
  }

  void _drawParticles(Canvas canvas) {
    final dot = Paint()..color = Colors.white.withOpacity(0.34);
    const points = [
      Offset(142, 214),
      Offset(336, 182),
      Offset(498, 226),
      Offset(638, 328),
      Offset(286, 620),
      Offset(184, 874),
      Offset(538, 956),
      Offset(216, 1322),
      Offset(360, 1460),
      Offset(518, 1718),
      Offset(168, 1908),
      Offset(612, 2124),
      Offset(262, 2362),
      Offset(146, 2616),
    ];
    for (final point in points) {
      canvas.drawCircle(point, 1.4, dot);
    }
  }

  void _drawGhostArch(
    Canvas canvas, {
    required Rect rect,
    required double opacity,
    required double angle,
  }) {
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(angle);
    canvas.translate(-rect.center.dx, -rect.center.dy);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(52),
        topRight: const Radius.circular(52),
        bottomLeft: const Radius.circular(24),
        bottomRight: const Radius.circular(24),
      ),
      Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.restore();
  }

  void _drawSupportCapsule(
    Canvas canvas, {
    required Rect rect,
    required Color color,
    required double opacity,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.46)),
      Paint()..color = color.withOpacity(opacity),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rect.center.dx, rect.top + rect.height * 0.32),
        width: rect.width * 0.56,
        height: rect.width * 0.56,
      ),
      Paint()..color = Colors.white.withOpacity(opacity * 0.7),
    );
  }

  void _drawPlatform(
    Canvas canvas, {
    required Rect rect,
    required Color top,
    required Color front,
    required Color side,
  }) {
    const skew = 26.0;
    final topFace = Path()
      ..moveTo(rect.left + skew, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right - skew, rect.top + rect.height * 0.24)
      ..lineTo(rect.left, rect.top + rect.height * 0.24)
      ..close();
    final frontFace = Path()
      ..moveTo(rect.left, rect.top + rect.height * 0.24)
      ..lineTo(rect.right - skew, rect.top + rect.height * 0.24)
      ..lineTo(rect.right - skew, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
    final sideFace = Path()
      ..moveTo(rect.right, rect.top)
      ..lineTo(rect.right - skew, rect.top + rect.height * 0.24)
      ..lineTo(rect.right - skew, rect.bottom)
      ..lineTo(rect.right, rect.bottom - rect.height * 0.24)
      ..close();

    canvas.drawShadow(frontFace, const Color(0x152E3557), 12, false);
    canvas.drawPath(topFace, Paint()..color = top);
    canvas.drawPath(frontFace, Paint()..color = front);
    canvas.drawPath(sideFace, Paint()..color = side);
  }

  void _drawRope(Canvas canvas, Offset start, Offset end) {
    _drawLadderBridge(
      canvas,
      start,
      end,
      railOffset: 6.5,
      railWidth: 3.4,
      rungWidth: 2.6,
      rungSpacing: 26,
    );
  }

  void _drawLadder(Canvas canvas, Offset start, Offset end) {
    _drawLadderBridge(
      canvas,
      start,
      end,
      railOffset: 8.0,
      railWidth: 3.8,
      rungWidth: 2.8,
      rungSpacing: 24,
    );
  }

  void _drawStairRibbon(Canvas canvas, Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length == 0) return;

    final ux = dx / length;
    final uy = dy / length;
    final nx = -uy;
    final ny = ux;

    final beam = Paint()
      ..color = const Color(0x2ED7C8F0)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, beam);

    final rungPaint = Paint()
      ..color = const Color(0xFFEFE5C7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final rungs = math.max(5, (length / 30).floor());
    for (var i = 0; i < rungs; i++) {
      final t = (i + 1) / (rungs + 1);
      final cx = start.dx + dx * t;
      final cy = start.dy + dy * t;
      canvas.drawLine(
        Offset(cx - nx * 11, cy - ny * 11),
        Offset(cx + nx * 7, cy + ny * 7),
        rungPaint,
      );
    }
  }

  void _drawLadderBridge(
    Canvas canvas,
    Offset start,
    Offset end, {
    required double railOffset,
    required double railWidth,
    required double rungWidth,
    required double rungSpacing,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length == 0) return;

    final ux = dx / length;
    final uy = dy / length;
    final nx = -uy;
    final ny = ux;

    final leftStart = Offset(start.dx + nx * railOffset, start.dy + ny * railOffset);
    final leftEnd = Offset(end.dx + nx * railOffset, end.dy + ny * railOffset);
    final rightStart = Offset(start.dx - nx * railOffset, start.dy - ny * railOffset);
    final rightEnd = Offset(end.dx - nx * railOffset, end.dy - ny * railOffset);

    final shadow = Paint()
      ..color = const Color(0x16343A5E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = railWidth + 2.2
      ..strokeCap = StrokeCap.round;
    final rail = Paint()
      ..color = const Color(0xFFE8D9B6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = railWidth
      ..strokeCap = StrokeCap.round;
    final highlight = Paint()
      ..color = const Color(0xFFFFF3DA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = railWidth * 0.42
      ..strokeCap = StrokeCap.round;
    final rung = Paint()
      ..color = const Color(0xFFF6EDD6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = rungWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(leftStart, leftEnd, shadow);
    canvas.drawLine(rightStart, rightEnd, shadow);
    canvas.drawLine(leftStart, leftEnd, rail);
    canvas.drawLine(rightStart, rightEnd, rail);
    canvas.drawLine(leftStart, leftEnd, highlight);
    canvas.drawLine(rightStart, rightEnd, highlight);

    final rungCount = math.max(4, (length / rungSpacing).floor());
    for (var i = 0; i < rungCount; i++) {
      final t = (i + 1) / (rungCount + 1);
      final cx = start.dx + dx * t;
      final cy = start.dy + dy * t;
      final rungInset = railOffset * 0.14;
      canvas.drawLine(
        Offset(cx - nx * (railOffset - rungInset), cy - ny * (railOffset - rungInset)),
        Offset(cx + nx * (railOffset - rungInset), cy + ny * (railOffset - rungInset)),
        rung,
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
  bool shouldRepaint(covariant _CourseScenePainter oldDelegate) => false;
}

class _PrimaryBridgeOverlayPainter extends CustomPainter {
  const _PrimaryBridgeOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawLadderBridge(
      canvas,
      const Offset(176, 262),
      const Offset(526, 438),
      railOffset: 8.2,
      railWidth: 3.9,
      rungWidth: 2.9,
      rungSpacing: 24,
    );
    _drawLadderBridge(
      canvas,
      const Offset(522, 486),
      const Offset(352, 826),
      railOffset: 7.6,
      railWidth: 3.7,
      rungWidth: 2.8,
      rungSpacing: 24,
    );
  }

  void _drawLadderBridge(
    Canvas canvas,
    Offset start,
    Offset end, {
    required double railOffset,
    required double railWidth,
    required double rungWidth,
    required double rungSpacing,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length == 0) return;

    final nx = -(dy / length);
    final ny = dx / length;

    final leftStart =
        Offset(start.dx + nx * railOffset, start.dy + ny * railOffset);
    final leftEnd = Offset(end.dx + nx * railOffset, end.dy + ny * railOffset);
    final rightStart =
        Offset(start.dx - nx * railOffset, start.dy - ny * railOffset);
    final rightEnd = Offset(end.dx - nx * railOffset, end.dy - ny * railOffset);

    final shadow = Paint()
      ..color = const Color(0x16343A5E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = railWidth + 2.2
      ..strokeCap = StrokeCap.round;
    final rail = Paint()
      ..color = const Color(0xFFE8D9B6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = railWidth
      ..strokeCap = StrokeCap.round;
    final highlight = Paint()
      ..color = const Color(0xFFFFF3DA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = railWidth * 0.42
      ..strokeCap = StrokeCap.round;
    final rung = Paint()
      ..color = const Color(0xFFF6EDD6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = rungWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(leftStart, leftEnd, shadow);
    canvas.drawLine(rightStart, rightEnd, shadow);
    canvas.drawLine(leftStart, leftEnd, rail);
    canvas.drawLine(rightStart, rightEnd, rail);
    canvas.drawLine(leftStart, leftEnd, highlight);
    canvas.drawLine(rightStart, rightEnd, highlight);

    final rungCount = math.max(4, (length / rungSpacing).floor());
    for (var i = 0; i < rungCount; i++) {
      final t = (i + 1) / (rungCount + 1);
      final cx = start.dx + dx * t;
      final cy = start.dy + dy * t;
      final rungInset = railOffset * 0.14;
      canvas.drawLine(
        Offset(
          cx - nx * (railOffset - rungInset),
          cy - ny * (railOffset - rungInset),
        ),
        Offset(
          cx + nx * (railOffset - rungInset),
          cy + ny * (railOffset - rungInset),
        ),
        rung,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PrimaryBridgeOverlayPainter oldDelegate) =>
      false;
}
