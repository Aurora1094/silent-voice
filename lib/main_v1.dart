import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const SignLanguageApp());
}

class SignLanguageApp extends StatelessWidget {
  const SignLanguageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '让我听见你',
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
  int currentIndex = 0;
  late Timer _timer;
  String timeText = _formatTime(DateTime.now());

  final List<RecognitionSample> samples = const [
    RecognitionSample(
      word: '你好',
      confidence: '94%',
      feedback: '识别良好：摆动方向正确，可以再把手掌抬高一点，效果会更稳定。',
    ),
    RecognitionSample(
      word: '谢谢',
      confidence: '91%',
      feedback: '动作路径基本正确，建议从下巴前方更自然地向外送出。',
    ),
    RecognitionSample(
      word: '喜欢',
      confidence: '88%',
      feedback: '胸口定位不错，下一步可以减小动作幅度，让表达更自然。',
    ),
    RecognitionSample(
      word: '我',
      confidence: '96%',
      feedback: '动作清晰，镜头取景稳定，已经可以进入短句练习。',
    ),
  ];

  bool cameraStarted = false;
  String modeText = '演示模式';
  String recognitionText = '等待识别：请点击“开始镜头”或“模拟识别”';
  String confidenceText = '--';
  String feedbackText = '当前建议：保持手掌完整进入取景框，放慢动作速度，先对齐“你好”的起始姿态。';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        timeText = _formatTime(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  static String _formatTime(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  void mockRecognize() {
    final item = samples[math.Random().nextInt(samples.length)];
    setState(() {
      recognitionText = '识别结果：${item.word}';
      confidenceText = item.confidence;
      feedbackText = item.feedback;
      modeText = 'AI 正在陪练';
      currentIndex = 2;
    });
  }

  void startCamera() {
    setState(() {
      cameraStarted = true;
      modeText = '镜头已开启';
      recognitionText = '镜头准备就绪：点击“模拟识别”查看教学反馈';
      confidenceText = 'Live';
      feedbackText = '后续可接入 camera / google_mlkit_pose_detection / MediaPipe Hands 做真实识别。';
      currentIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6EFE7),
              Color(0xFFD9D4F7),
              Color(0xFFA8C6D8),
            ],
            stops: [0.0, 0.52, 1.0],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: MonumentWorldBackground()),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.min(420, size.width),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(38),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(38),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E3557).withOpacity(0.22),
                                blurRadius: 65,
                                offset: const Offset(0, 25),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 10,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    width: 136,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xE02E3557),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                                child: IndexedStack(
                                  index: currentIndex,
                                  children: [
                                    HomeScreen(
                                      timeText: timeText,
                                      onPracticeTap: () => setState(() => currentIndex = 2),
                                      onLessonsTap: () => setState(() => currentIndex = 1),
                                    ),
                                    LessonsScreen(onTabChanged: _changeTab),
                                    PracticeScreen(
                                      modeText: modeText,
                                      recognitionText: recognitionText,
                                      confidenceText: confidenceText,
                                      feedbackText: feedbackText,
                                      cameraStarted: cameraStarted,
                                      onStartCamera: startCamera,
                                      onMockRecognize: mockRecognize,
                                      onTabChanged: _changeTab,
                                    ),
                                    StoryScreen(onTabChanged: _changeTab),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeTab(int index) {
    setState(() => currentIndex = index);
  }
}

class RecognitionSample {
  final String word;
  final String confidence;
  final String feedback;

  const RecognitionSample({
    required this.word,
    required this.confidence,
    required this.feedback,
  });
}

class MonumentWorldBackground extends StatelessWidget {
  const MonumentWorldBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 56,
          right: MediaQuery.of(context).size.width * 0.12,
          child: Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.3, -0.3),
                radius: 0.9,
                colors: [
                  Color(0xFFFFF9E8),
                  Color(0xFFF6D9A1),
                  Color(0x33F6D9A1),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          left: 50,
          top: 150,
          child: DecorativeArch(),
        ),
        const Positioned(
          left: 25,
          bottom: 110,
          child: DecorativeTower(
            width: 120,
            height: 280,
            colors: [Color(0xFFF8D0C4), Color(0xFFD8999E)],
            angle: -0.18,
          ),
        ),
        const Positioned(
          right: 34,
          bottom: 85,
          child: DecorativeTower(
            width: 150,
            height: 220,
            colors: [Color(0xFFB9DCE7), Color(0xFF84AFBD)],
            angle: 0.16,
          ),
        ),
        const Positioned(
          left: 60,
          bottom: 150,
          child: DecorativeStep(
            width: 160,
            height: 22,
            color: Color(0xFFF6E8DA),
            angle: -0.15,
          ),
        ),
        const Positioned(
          right: 70,
          bottom: 190,
          child: DecorativeStep(
            width: 120,
            height: 18,
            color: Color(0xFFFFF2D3),
            angle: 0.21,
          ),
        ),
      ],
    );
  }
}

class DecorativeTower extends StatelessWidget {
  final double width;
  final double height;
  final List<Color> colors;
  final double angle;

  const DecorativeTower({
    super.key,
    required this.width,
    required this.height,
    required this.colors,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
          boxShadow: [softShadow],
        ),
      ),
    );
  }
}

class DecorativeStep extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double angle;

  const DecorativeStep({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E3557).withOpacity(0.14),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      ),
    );
  }
}

class DecorativeArch extends StatelessWidget {
  const DecorativeArch({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.14,
      child: Container(
        width: 86,
        height: 128,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.28),
          border: Border.all(color: Colors.white.withOpacity(0.35), width: 4),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String timeText;
  final VoidCallback onPracticeTap;
  final VoidCallback onLessonsTap;

  const HomeScreen({
    super.key,
    required this.timeText,
    required this.onPracticeTap,
    required this.onLessonsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TopBar(
          leadingText: timeText,
          trailing: const SoftPill(text: '愿每一个手势都被看见'),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeroCard(
                  onPracticeTap: onPracticeTap,
                  onLessonsTap: onLessonsTap,
                ),
                const SizedBox(height: 14),
                const SectionTitle(title: '今日旅程', trailing: 'Monument Valley Mood'),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.94,
                  children: const [
                    MiniFeatureCard(
                      icon: '🤟',
                      title: '基础手势',
                      desc: '从问候、感谢、我、你开始，先建立最温柔的第一步。',
                      colors: [Color(0xFFFFE7DD), Color(0xFFFFD1CB)],
                    ),
                    MiniFeatureCard(
                      icon: '📷',
                      title: '实时识别',
                      desc: '镜头示范 + 动作纠正，让练习不只是“看”，而是“做出来”。',
                      colors: [Color(0xFFF9EFCF), Color(0xFFF2D889)],
                    ),
                    MiniFeatureCard(
                      icon: '🫶',
                      title: '温柔陪练',
                      desc: '把错误提示做得更轻一点，像陪伴而不是打分。',
                      colors: [Color(0xFFDFF7F1), Color(0xFFA8E0D4)],
                    ),
                    MiniFeatureCard(
                      icon: '✨',
                      title: '故事章节',
                      desc: '把课程做成章节旅程，让学习像走入一座安静建筑。',
                      colors: [Color(0xFFE5E9FF), Color(0xFFC7D0FF)],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const WeeklyProgressCard(),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
        BottomNav(currentIndex: 0, onChanged: (v) {
          if (v == 1) onLessonsTap();
          if (v == 2) onPracticeTap();
        }),
      ],
    );
  }
}

class MazeLesson {
  final String title;
  final String subtitle;
  final String duration;
  final String description;
  final String icon;
  final List<String> steps;
  final List<Color> colors;
  final int lane; // 0: 左, 1: 右, 2: 中
  final double top;
  final bool locked;

  const MazeLesson({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.description,
    required this.icon,
    required this.steps,
    required this.colors,
    required this.lane,
    required this.top,
    this.locked = false,
  });
}

const List<MazeLesson> mazeLessons = [
  MazeLesson(
    title: '第 1 课 · 你好',
    subtitle: '晨光问候',
    duration: '6 min',
    description: '掌心向外，轻轻摆动，完成最基础的问候动作。',
    icon: '👋',
    steps: [
      '先看一遍示范动作',
      '对着镜子跟练 3 次',
      '进入练习页做镜头识别',
    ],
    colors: [Color(0xFFFFE8DC), Color(0xFFFFCDBA)],
    lane: 0,
    top: 20,
  ),
  MazeLesson(
    title: '第 2 课 · 谢谢',
    subtitle: '暖光回应',
    duration: '7 min',
    description: '从下巴前方向外送出，注意起始点和动作方向。',
    icon: '🙏',
    steps: [
      '观察起手位置',
      '练习向外送出的路径',
      '做一次完整识别反馈',
    ],
    colors: [Color(0xFFFFF2D9), Color(0xFFF4D98D)],
    lane: 1,
    top: 165,
  ),
  MazeLesson(
    title: '第 3 课 · 喜欢',
    subtitle: '贴近心口',
    duration: '8 min',
    description: '将动作与情绪表达结合，让词汇更有温度。',
    icon: '💗',
    steps: [
      '看胸口定位点',
      '减少多余摆动',
      '完成 3 次平滑练习',
    ],
    colors: [Color(0xFFE7F8F2), Color(0xFFAEE2D7)],
    lane: 2,
    top: 320,
  ),
  MazeLesson(
    title: '第 4 课 · 你还好吗',
    subtitle: '温柔关心',
    duration: '10 min',
    description: '把问候从单字升级成一句完整表达。',
    icon: '🌙',
    steps: [
      '拆开成 2 个动作段',
      '连接成完整短句',
      '进入实战练习页',
    ],
    colors: [Color(0xFFE7EBFF), Color(0xFFC9D2FF)],
    lane: 0,
    top: 495,
  ),
  MazeLesson(
    title: '第 5 课 · 我想你',
    subtitle: '下一章节',
    duration: '12 min',
    description: '加入情绪层次和更自然的动作节奏。',
    icon: '✨',
    steps: [
      '完成前置课程',
      '解锁新的章节地图',
      '开始连续表达训练',
    ],
    colors: [Color(0xFFF1E8FF), Color(0xFFD8C5F4)],
    lane: 1,
    top: 655,
    locked: true,
  ),
];

class LessonsScreen extends StatelessWidget {
  final ValueChanged<int> onTabChanged;

  const LessonsScreen({super.key, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TopBar(
          leadingText: '课程迷宫',
          trailing: SoftPill(text: '点击平台进入每节课'),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FrostCard(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(
                        title: '纪念碑谷式课程地图',
                        trailing: 'Maze Chapter 01',
                        compact: true,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '把每一节课放到悬浮平台上，用桥梁把学习路径连起来。用户不是在“刷列表”，而是在“走进一座课程建筑”。',
                        style: mutedStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final nodeWidth = math.min(188.0, constraints.maxWidth * 0.54);

                    return SizedBox(
                      height: 860,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: MazeRoadPainter(
                                lessons: mazeLessons,
                                nodeWidth: nodeWidth,
                              ),
                            ),
                          ),
                          Positioned(
                            left: constraints.maxWidth * 0.34,
                            top: 0,
                            child: const _MiniArchDecoration(),
                          ),
                          Positioned(
                            right: 6,
                            top: 105,
                            child: const _MiniTowerDecoration(
                              height: 118,
                              colors: [Color(0xFFD9EEF5), Color(0xFFA6C8D4)],
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 585,
                            child: const _MiniTowerDecoration(
                              height: 104,
                              colors: [Color(0xFFF7DACC), Color(0xFFDDA2A8)],
                            ),
                          ),
                          ...mazeLessons.map(
                                (lesson) => Positioned(
                              top: lesson.top,
                              left: _laneLeft(lesson.lane, constraints.maxWidth, nodeWidth),
                              child: MazeLessonNode(
                                width: nodeWidth,
                                lesson: lesson,
                                onTap: lesson.locked
                                    ? null
                                    : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => LessonDetailPage(
                                        lesson: lesson,
                                        onStartLesson: () {
                                          Navigator.of(context).pop();
                                          onTabChanged(2);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        BottomNav(currentIndex: 1, onChanged: onTabChanged),
      ],
    );
  }
}

double _laneLeft(int lane, double width, double nodeWidth) {
  switch (lane) {
    case 0:
      return 6;
    case 1:
      return width - nodeWidth - 6;
    case 2:
      return (width - nodeWidth) / 2;
    default:
      return 0;
  }
}

class MazeRoadPainter extends CustomPainter {
  final List<MazeLesson> lessons;
  final double nodeWidth;

  MazeRoadPainter({
    required this.lessons,
    required this.nodeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = const Color(0x142E3557)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final linePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xCCFFF4E6),
          Color(0xCCDDEEFF),
          Color(0xCCF6D9E8),
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < lessons.length - 1; i++) {
      final a = _centerOf(lessons[i], size.width);
      final b = _centerOf(lessons[i + 1], size.width);
      final midY = (a.dy + b.dy) / 2;

      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(
          a.dx,
          midY - 45,
          b.dx,
          midY + 45,
          b.dx,
          b.dy,
        );

      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, linePaint);
    }

    for (final lesson in lessons) {
      final center = _centerOf(lesson, size.width);
      canvas.drawCircle(center, 10, glowPaint);
      canvas.drawCircle(
        center,
        5.5,
        Paint()..color = const Color(0xFF2E3557).withOpacity(0.35),
      );
    }
  }

  Offset _centerOf(MazeLesson lesson, double width) {
    final left = _laneLeft(lesson.lane, width, nodeWidth);
    return Offset(left + nodeWidth / 2, lesson.top + 74);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MazeLessonNode extends StatelessWidget {
  final double width;
  final MazeLesson lesson;
  final VoidCallback? onTap;

  const MazeLessonNode({
    super.key,
    required this.width,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayColors = lesson.locked
        ? const [Color(0xFFF2F1F7), Color(0xFFDDD8EA)]
        : lesson.colors;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: lesson.locked ? 0.78 : 1,
        child: SizedBox(
          width: width,
          height: 150,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 18,
                right: 18,
                bottom: 4,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        displayColors.last.withOpacity(0.95),
                        displayColors.first.withOpacity(0.70),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E3557).withOpacity(0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: lesson.lane == 1 ? null : 18,
                right: lesson.lane == 1 ? 18 : null,
                bottom: 26,
                child: Transform.rotate(
                  angle: lesson.lane == 1 ? 0.24 : -0.24,
                  child: Container(
                    width: 56,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6EC),
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E3557).withOpacity(0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: displayColors,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.72),
                      width: 1.2,
                    ),
                    boxShadow: [softShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.62),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              lesson.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.white.withOpacity(0.54),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  lesson.locked
                                      ? Icons.lock_outline_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: const Color(0xFF5F678F),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  lesson.locked ? '未解锁' : '进入',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF5F678F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E3557),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5F678F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            lesson.duration,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0x992E3557),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            lesson.locked ? '完成前一课后解锁' : '点击查看课程',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0x992E3557),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class LessonDetailPage extends StatelessWidget {
  final MazeLesson lesson;
  final VoidCallback onStartLesson;

  const LessonDetailPage({
    super.key,
    required this.lesson,
    required this.onStartLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7F0E8),
              Color(0xFFD9D5F8),
              Color(0xFFA8C8D9),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: MonumentWorldBackground()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.58),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Color(0xFF2E3557),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E3557),
                            ),
                          ),
                        ),
                        SoftPill(text: lesson.duration),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: lesson.colors,
                                ),
                                boxShadow: [softShadow],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 78,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.60),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      lesson.icon,
                                      style: const TextStyle(fontSize: 34),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lesson.subtitle,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xAA2E3557),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          lesson.description,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.65,
                                            color: Color(0xFF2E3557),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            FrostCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionTitle(
                                    title: '本节目标',
                                    trailing: 'Lesson Goal',
                                    compact: true,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '这一节的重点不是“背动作”，而是先让用户理解动作的起点、路径和情绪语气。',
                                    style: mutedStyle,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            FrostCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionTitle(
                                    title: '学习路径',
                                    trailing: '3 Steps',
                                    compact: true,
                                  ),
                                  const SizedBox(height: 12),
                                  ...lesson.steps.asMap().entries.map(
                                        (entry) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withOpacity(0.72),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${entry.key + 1}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF2E3557),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 3),
                                              child: Text(
                                                entry.value,
                                                style: mutedStyle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const FrostCard(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionTitle(
                                    title: '完成后去哪里',
                                    trailing: 'Next',
                                    compact: true,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '学完这一节，直接跳到“练习”页，用镜头识别去判断动作有没有做到位。这样课程页负责沉浸感，练习页负责反馈闭环。',
                                    style: mutedStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: '开始这一课',
                            onTap: onStartLesson,
                            primary: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniArchDecoration extends StatelessWidget {
  const _MiniArchDecoration();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.65,
      child: Transform.scale(
        scale: 0.82,
        child: const DecorativeArch(),
      ),
    );
  }
}

class _MiniTowerDecoration extends StatelessWidget {
  final double height;
  final List<Color> colors;

  const _MiniTowerDecoration({
    required this.height,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.78,
      child: Transform.rotate(
        angle: 0.12,
        child: Container(
          width: 48,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E3557).withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeScreen extends StatelessWidget {
  final String modeText;
  final String recognitionText;
  final String confidenceText;
  final String feedbackText;
  final bool cameraStarted;
  final VoidCallback onStartCamera;
  final VoidCallback onMockRecognize;
  final ValueChanged<int> onTabChanged;

  const PracticeScreen({
    super.key,
    required this.modeText,
    required this.recognitionText,
    required this.confidenceText,
    required this.feedbackText,
    required this.cameraStarted,
    required this.onStartCamera,
    required this.onMockRecognize,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TopBar(
          leadingText: '实时练习',
          trailing: SoftPill(text: modeText),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FrostCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: 'CV 手势识别 Demo', trailing: '前端模拟版', compact: true),
                      const SizedBox(height: 10),
                      Text(
                        '这里先用 Flutter 做一个手机端演示。接入真实 CV 时，可以换成 camera + MediaPipe Hands / ML Kit / 后端识别接口。',
                        style: mutedStyle,
                      ),
                      const SizedBox(height: 14),
                      CameraDemoBox(
                        cameraStarted: cameraStarted,
                        recognitionText: recognitionText,
                        confidenceText: confidenceText,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              label: '开始镜头',
                              onTap: onStartCamera,
                              primary: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GradientButton(
                              label: '模拟识别',
                              onTap: onMockRecognize,
                              primary: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FrostCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: '动作反馈', trailing: '给用户即时鼓励', compact: true),
                      const SizedBox(height: 10),
                      Text(feedbackText, style: mutedStyle),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const FrostCard(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(title: '可扩展的真实功能', trailing: '适合比赛答辩', compact: true),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          TagChip(text: '关键点骨架可视化'),
                          TagChip(text: '错误动作纠正'),
                          TagChip(text: '慢动作分解教学'),
                          TagChip(text: '跟练评分'),
                          TagChip(text: '家长/老师端报告'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
        BottomNav(currentIndex: 2, onChanged: onTabChanged),
      ],
    );
  }
}

class StoryScreen extends StatelessWidget {
  final ValueChanged<int> onTabChanged;

  const StoryScreen({super.key, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TopBar(
          leadingText: '品牌故事',
          trailing: SoftPill(text: '让表达被看见'),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                StoryHeroCard(),
                SizedBox(height: 12),
                StoryTextCard(
                  title: '适合做成比赛项目的亮点',
                  text: '1）手语识别 + 教学闭环；2）有社会关怀价值；3）手机端易落地；4）适合加入 AI 陪练、表情反馈、学习成长体系。',
                ),
                SizedBox(height: 12),
                StoryTextCard(
                  title: '后续技术路线',
                  text: '前端负责摄像头采集与交互；CV 模块可用 MediaPipe Hands 提取关键点；分类模型可先做静态词汇识别，再升级到动态短句识别；最后加入教学内容管理和用户进度系统。',
                ),
                SizedBox(height: 12),
                StoryTextCard(
                  title: '一句话介绍',
                  text: '一款基于计算机视觉的手机端手语教学 App，通过实时动作识别、分步示范与情境化课程，帮助更多人温柔地学会“看见彼此”。',
                ),
                SizedBox(height: 12),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Demo by Flutter · Visual mood inspired by impossible architecture and poetic calm',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Color(0x8C2E3557)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        BottomNav(currentIndex: 3, onChanged: onTabChanged),
      ],
    );
  }
}

class HeroCard extends StatelessWidget {
  final VoidCallback onPracticeTap;
  final VoidCallback onLessonsTap;

  const HeroCard({
    super.key,
    required this.onPracticeTap,
    required this.onLessonsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 245),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.82),
            Colors.white.withOpacity(0.42),
          ],
        ),
        boxShadow: [softShadow],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 24,
            bottom: 18,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.skewY(-0.22),
              child: Container(
                width: 110,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFB7D2DC), Color(0xFF88A9BB)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 72,
            bottom: 116,
            child: Transform.rotate(
              angle: -0.24,
              child: Container(
                width: 82,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8EBD5),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E3557).withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SoftPill(text: 'CV 手语识别 × 沉浸式教学'),
              const SizedBox(height: 10),
              const SizedBox(
                width: 180,
                child: Text(
                  '让我\n听见你',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.08,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E3557),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(
                width: 210,
                child: Text(
                  '一个面向手机端的手语教学 Demo。用镜头捕捉动作，用温柔的界面陪你从“看见手势”走到“理解表达”。',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    color: Color(0xFF5F678F),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      label: '开始练习',
                      onTap: onPracticeTap,
                      primary: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GradientButton(
                      label: '课程地图',
                      onTap: onLessonsTap,
                      primary: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MiniFeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;
  final List<Color> colors;

  const MiniFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return FrostCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: colors),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E3557),
            ),
          ),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 12, height: 1.6, color: Color(0xFF5F678F))),
        ],
      ),
    );
  }
}

class WeeklyProgressCard extends StatelessWidget {
  const WeeklyProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.72),
            Colors.white.withOpacity(0.48),
          ],
        ),
        boxShadow: [softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '本周进度', trailing: '62%', compact: true),
          const SizedBox(height: 8),
          Text(
            '已掌握 18 个基础手语，完成 4 次镜头练习，今天距离点亮新章节只差一步。',
            style: mutedStyle,
          ),
          const SizedBox(height: 12),
          Container(
            height: 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: const Color(0xFF5F678F).withOpacity(0.12),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC8B3), Color(0xFFF2E099), Color(0xFFA4E0D6)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BubbleList extends StatelessWidget {
  const BubbleList({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('🌤️ 晨光问候', '5 个基础手势'),
      ('🌊 情绪表达', '开心 / 难过 / 想念'),
      ('🏠 生活交流', '吃饭 / 回家 / 学习'),
      ('✨ 社交短句', '完整表达训练'),
    ];

    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 132,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.58),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E3557).withOpacity(0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.$1, style: const TextStyle(fontSize: 13, color: Color(0xFF5F678F))),
                const SizedBox(height: 4),
                Text(item.$2, style: const TextStyle(fontSize: 11, color: Color(0x8C2E3557))),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;

  const LessonCard({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return FrostCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF4EA), Color(0xFFFFD9C9)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2E3557)),
                ),
                const SizedBox(height: 6),
                Text(desc, style: mutedStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CameraDemoBox extends StatefulWidget {
  final bool cameraStarted;
  final String recognitionText;
  final String confidenceText;

  const CameraDemoBox({
    super.key,
    required this.cameraStarted,
    required this.recognitionText,
    required this.confidenceText,
  });

  @override
  State<CameraDemoBox> createState() => _CameraDemoBoxState();
}

class _CameraDemoBoxState extends State<CameraDemoBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x61A4CAD6), Color(0x24FFFFFF)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD6EEF2), Color(0xFFF0E2F1)],
                ),
              ),
            ),
            if (widget.cameraStarted)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF99B8C3).withOpacity(0.20),
                        const Color(0xFF6B8296).withOpacity(0.34),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Camera Preview Placeholder',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              )
            else
              const Center(child: CameraHandArt()),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final scale = 1 + (_controller.value * 0.03);
                final opacity = 0.45 + ((1 - _controller.value) * 0.35);
                return Center(
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0x402E3557).withOpacity(opacity),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withOpacity(0.70),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E3557).withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.recognitionText,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF2E3557)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.confidenceText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E3557),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraHandArt extends StatelessWidget {
  const CameraHandArt({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        children: const [
          Positioned(left: 44, top: 52, child: HandPalm()),
          Positioned(left: 50, top: 6, child: HandFinger(height: 72, width: 20)),
          Positioned(left: 74, top: 0, child: HandFinger(height: 82, width: 20)),
          Positioned(left: 98, top: 8, child: HandFinger(height: 76, width: 20)),
          Positioned(left: 120, top: 24, child: HandFinger(height: 62, width: 18)),
          Positioned(left: 22, top: 74, child: RotatedBox(quarterTurns: 1, child: HandFinger(height: 56, width: 26))),
        ],
      ),
    );
  }
}

class HandPalm extends StatelessWidget {
  const HandPalm({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.17,
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF6ED), Color(0xFFFFD8C7)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E3557).withOpacity(0.12),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      ),
    );
  }
}

class HandFinger extends StatelessWidget {
  final double width;
  final double height;

  const HandFinger({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF6ED), Color(0xFFFFD8C7)],
        ),
      ),
    );
  }
}

class StoryHeroCard extends StatelessWidget {
  const StoryHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FrostCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '“声音并不是唯一的语言，\n手势也可以让世界安静地亮起来。”',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.55,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E3557),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '“让我听见你”不是要把手语变成冷冰冰的技术展示，而是让更多人愿意靠近、理解、学习与陪伴。',
                  style: TextStyle(fontSize: 12, height: 1.65, color: Color(0xFF5F678F)),
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

class StoryTextCard extends StatelessWidget {
  final String title;
  final String text;

  const StoryTextCard({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return FrostCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2E3557)),
          ),
          const SizedBox(height: 10),
          Text(text, style: mutedStyle),
        ],
      ),
    );
  }
}

class BigInfoCard extends StatelessWidget {
  final String title;
  final String trailing;
  final String description;
  final List<String> tags;

  const BigInfoCard({
    super.key,
    required this.title,
    required this.trailing,
    required this.description,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return FrostCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title, trailing: trailing, compact: true),
          const SizedBox(height: 10),
          Text(description, style: mutedStyle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((e) => TagChip(text: e)).toList(),
          ),
        ],
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  final String leadingText;
  final Widget trailing;

  const TopBar({
    super.key,
    required this.leadingText,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          leadingText,
          style: const TextStyle(
            fontSize: 13,
            letterSpacing: 0.06,
            color: Color(0xFF5F678F),
          ),
        ),
        trailing,
      ],
    );
  }
}

class SoftPill extends StatelessWidget {
  final String text;

  const SoftPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.55),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.60),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF5F678F)),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: primary
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFB9A3), Color(0xFFFFCFC1)],
          )
              : null,
          color: primary ? null : Colors.white.withOpacity(0.62),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E3557).withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: primary ? const Color(0xFF2E3557) : const Color(0xFF5F678F),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String trailing;
  final bool compact;

  const SectionTitle({
    super.key,
    required this.title,
    required this.trailing,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: compact ? 18 : 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E3557),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(fontSize: 12, color: Color(0xFF5F678F)),
        ),
      ],
    );
  }
}

class FrostCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const FrostCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.60),
        boxShadow: [softShadow],
      ),
      child: child,
    );
  }
}

class TagChip extends StatelessWidget {
  final String text;

  const TagChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.66),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF5F678F)),
      ),
    );
  }
}

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      ('🏠', '首页'),
      ('🗺️', '课程'),
      ('📸', '练习'),
      ('💬', '故事'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.45),
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
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: active ? Colors.white.withOpacity(0.72) : Colors.transparent,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(items[index].$1, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      items[index].$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? const Color(0xFF2E3557) : const Color(0xFF5F678F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

const mutedStyle = TextStyle(
  fontSize: 12,
  height: 1.65,
  color: Color(0xFF5F678F),
);

final softShadow = BoxShadow(
  color: const Color(0xFF2E3557).withOpacity(0.18),
  blurRadius: 40,
  offset: const Offset(0, 18),
);
