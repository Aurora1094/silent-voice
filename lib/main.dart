import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/camera/embedded_camera_preview.dart';
import 'src/course_map/monument_course_map_screen.dart';
import 'src/home/immersive_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SignLanguageApp());
}

class SignLanguageApp extends StatelessWidget {
  const SignLanguageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Silent Voice',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: GoogleFonts.notoSerifScTextTheme(),
      ),
      home: const MonumentValleyHome(),
    );
  }
}

class MonumentValleyHome extends StatefulWidget {
  const MonumentValleyHome({super.key});

  @override
  State<MonumentValleyHome> createState() => _MonumentValleyHomeState();
}

class _MonumentValleyHomeState extends State<MonumentValleyHome> {
  late final PageController _pageController;
  late List<bool> _learnedLessons;

  int _tabIndex = 0;
  int _sequentialProgressCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _learnedLessons = List<bool>.filled(courseMapLessons.length, false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int? get _currentLessonIndex {
    if (_sequentialProgressCount >= courseMapLessons.length) {
      return null;
    }
    return _sequentialProgressCount;
  }

  List<CourseMapLesson> get _runtimeLessons {
    final currentIndex = _currentLessonIndex;

    return List.generate(courseMapLessons.length, (index) {
      final template = courseMapLessons[index];
      final learned = _learnedLessons[index];
      final completed = index < _sequentialProgressCount;
      final isCurrent = currentIndex != null && index == currentIndex;

      final state = completed
          ? CourseMapLessonState.completed
          : isCurrent
              ? CourseMapLessonState.current
              : CourseMapLessonState.upcoming;

      return template.copyWith(
        state: state,
        learned: learned,
        progressLabel: completed
            ? '已计入进度'
            : isCurrent
                ? '当前课程'
                : learned
                    ? '已学习未计入'
                    : '可直接学习',
        progressValue: completed
            ? 1.0
            : isCurrent
                ? 0.56
                : learned
                    ? 0.22
                    : 0.08,
      );
    });
  }

  bool _advanceSequentialProgress() {
    final previous = _sequentialProgressCount;
    while (_sequentialProgressCount < _learnedLessons.length &&
        _learnedLessons[_sequentialProgressCount]) {
      _sequentialProgressCount++;
    }
    return _sequentialProgressCount != previous;
  }

  void _recordLessonPass(int index) {
    if (index < 0 || index >= courseMapLessons.length) {
      return;
    }

    setState(() {
      _learnedLessons[index] = true;
      _advanceSequentialProgress();
    });
  }

  Future<void> _changeTab(int index) async {
    if (index < 0 || index > 3) {
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _tabIndex = index;
    });

    if (!_pageController.hasClients) {
      return;
    }

    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openPractice() async {
    await _changeTab(2);
  }

  @override
  Widget build(BuildContext context) {
    final lessons = _runtimeLessons;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: AppBottomNav(
          currentIndex: _tabIndex,
          onChanged: (value) {
            _changeTab(value);
          },
        ),
      ),
      body: DecoratedBox(
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
        child: PageView(
          controller: _pageController,
          physics: const PageScrollPhysics(),
          onPageChanged: (value) {
            if (_tabIndex == value) {
              return;
            }
            setState(() {
              _tabIndex = value;
            });
          },
          children: [
            ImmersiveHomeScreen(
              lessons: lessons,
              onPracticeTap: () {
                _openPractice();
              },
              onLessonsTap: () {
                _changeTab(1);
              },
              onStoryTap: () {
                _changeTab(3);
              },
            ),
            MonumentCourseMapScreen(
              lessons: lessons,
              onTabChanged: (value) {
                _changeTab(value);
              },
              onStartLesson: (_) {},
              onLessonPassed: _recordLessonPass,
            ),
            const PracticeScreen(),
            StoryScreen(
              onOpenPractice: () {
                _openPractice();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top + 18;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18, topInset, 18, 20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScreenHeader(
            eyebrow: '实时练习',
            title: '手语识别',
            subtitle: '',
          ),
          SizedBox(height: 8),
          _GlassCard(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '识别演示',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF27314F),
                  ),
                ),
                SizedBox(height: 14),
                EmbeddedCameraPreview(),
              ],
            ),
          ),
          SizedBox(height: 14),
          _GlassCard(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '练习说明',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF27314F),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '把双手放在画面中央，先做清晰、完整的动作，再逐步提高速度。当前支持词汇会在识别卡片里直接显示。',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: Color(0xFF66708D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoryScreen extends StatefulWidget {
  const StoryScreen({
    super.key,
    required this.onOpenPractice,
  });

  final VoidCallback onOpenPractice;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  static const double _pullTriggerDistance = 96;

  double _pullDistance = 0;
  bool _isNavigating = false;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isNavigating) {
      return false;
    }

    if (notification is OverscrollNotification &&
        notification.dragDetails != null &&
        notification.metrics.pixels <= 0 &&
        notification.overscroll < 0) {
      final nextPullDistance = (_pullDistance - notification.overscroll)
          .clamp(0.0, _pullTriggerDistance)
          .toDouble();

      if (nextPullDistance != _pullDistance) {
        setState(() {
          _pullDistance = nextPullDistance;
        });
      }

      if (nextPullDistance >= _pullTriggerDistance) {
        _openPractice();
      }
      return false;
    }

    if (notification is ScrollUpdateNotification &&
        notification.metrics.pixels > 0 &&
        _pullDistance != 0) {
      setState(() {
        _pullDistance = 0;
      });
      return false;
    }

    if (notification is ScrollEndNotification && _pullDistance != 0) {
      setState(() {
        _pullDistance = 0;
      });
    }

    return false;
  }

  Future<void> _openPractice() async {
    if (_isNavigating) {
      return;
    }

    setState(() {
      _isNavigating = true;
      _pullDistance = _pullTriggerDistance;
    });

    await HapticFeedback.mediumImpact();
    widget.onOpenPractice();

    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) {
      return;
    }

    setState(() {
      _isNavigating = false;
      _pullDistance = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top + 18;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(18, topInset, 18, 88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StoryHeader(
              eyebrow: '公益故事',
              title: '让表达被看见',
              subtitle: 'Silent Voice',
            ),
            const SizedBox(height: 14),
            const _StoryHeroCard(),
            const SizedBox(height: 14),
            const _StoryTextCard(
              title: '有些距离，不是因为不想交流',
              text:
                  '对许多听障人士来说，困难往往不在“表达”，而在“表达没有被理解”。当习惯的沟通方式不同，误解、沉默和忽视就会悄悄出现。我们希望通过一次轻量但真实的体验，让更多同学意识到：无障碍沟通不是少数人的事，而是每个人都可以参与的公共关怀。',
            ),
            const SizedBox(height: 14),
            const _StoryTextCard(
              title: '把理解，变成一次可以参与的体验',
              text:
                  'Silent Voice 以基础手语学习、实时识别体验和互动反馈为入口，让第一次接触手语的人，也能在短时间里完成一次真切的尝试。我们不想只告诉你“应该关注”，而是希望你亲手做出一个动作，在体验中感受沟通的意义，在靠近中理解另一种表达方式。',
            ),
            const SizedBox(height: 14),
            const _StoryTextCard(
              title: '这次活动，想让更多人愿意靠近',
              text:
                  '这款 App 依托「减论」团队，作为南开大学软件学院学生会与南开大学爱心社手语部联合活动的宣传与互动入口。我们希望它帮助更多同学从“知道”走向“理解”，从“围观”走向“参与”，也让一次校园公益活动，真正成为一次关于尊重、沟通与陪伴的开始。',
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF7B85A2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xFF27314F),
          ),
        ),
        if (hasSubtitle) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF66708D),
            ),
          ),
        ],
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.54),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.72),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B4263).withOpacity(0.10),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StoryHeader extends StatelessWidget {
  const _StoryHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: GoogleFonts.notoSerifSc(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
            color: const Color(0xFF7B85A2),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.notoSerifSc(
            fontSize: 32,
            height: 1.18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF27314F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.notoSerifSc(
            fontSize: 13,
            height: 1.7,
            letterSpacing: 0.4,
            color: const Color(0xFF66708D),
          ),
        ),
      ],
    );
  }
}

class _StoryHeroCard extends StatelessWidget {
  const _StoryHeroCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '声音不是唯一的语言，\n沉默也不意味着\n无话可说',
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 22,
                    height: 1.55,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E3557),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '我们想做的，不只是一个可以识别手势的 App，更是一份温和的邀请。邀请更多人走近听障群体，理解他们在沟通中面对的真实处境，也学会用更尊重的方式彼此看见。',
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 13,
                    height: 1.85,
                    color: const Color(0xFF5F678F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 76,
            height: 106,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF3D3C2), Color(0xFFD59DA1)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  left: 21,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.78),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 44,
                  left: 17,
                  child: Container(
                    width: 42,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.60),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryTextCard extends StatelessWidget {
  const _StoryTextCard({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSerifSc(
              fontSize: 19,
              height: 1.45,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E3557),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: GoogleFonts.notoSerifSc(
              fontSize: 13,
              height: 1.88,
              color: const Color(0xFF5F678F),
            ),
          ),
        ],
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const List<_NavItemData> _items = [
    _NavItemData(icon: Icons.home_rounded, label: '首页'),
    _NavItemData(icon: Icons.map_outlined, label: '课程'),
    _NavItemData(icon: Icons.center_focus_strong_rounded, label: '练习'),
    _NavItemData(icon: Icons.auto_stories_outlined, label: '故事'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.58),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.74),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E3557).withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == currentIndex;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onChanged(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFFFE0D5)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: 21,
                            color: selected
                                ? const Color(0xFF2E3557)
                                : const Color(0xFF7B85A2),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.0,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? const Color(0xFF2E3557)
                                  : const Color(0xFF7B85A2),
                            ),
                          ),
                        ],
                      ),
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

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
