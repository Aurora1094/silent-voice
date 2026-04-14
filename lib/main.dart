
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

// ─── CV 识别阶段 ────────────────────────────────────────────────────────────
enum CVPhase { idle, scanning, detecting, matched }

// 全局摄像头列表，在 main() 中初始化
List<CameraDescription> _cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    _cameras = await availableCameras();
  } catch (_) {
    _cameras = [];
  }
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
  late PageController _pageController;
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
  String feedbackText =
      '当前建议：保持手掌完整进入取景框，放慢动作速度，先对齐“你好”的起始姿态。';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        timeText = _formatTime(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
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
    });
    _changeTab(2);
  }

  void startCamera() {
    setState(() {
      cameraStarted = true;
      modeText = '镜头已开启';
      recognitionText = '镜头准备就绪：点击"模拟识别"查看教学反馈';
      confidenceText = 'Live';
      feedbackText =
      '后续可接入 camera / google_mlkit_pose_detection / MediaPipe Hands 做真实识别。';
    });
    _changeTab(2);
  }

  void _changeTab(int index) {
    setState(() => currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: LayoutBuilder(
                  builder: (context, viewport) {
                    return Center(
                      child: SizedBox(
                        width: math.min(420.0, viewport.maxWidth),
                        height: viewport.maxHeight,
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
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  16,
                                ),
                                child: PageView(
                                  controller: _pageController,
                                  physics: const ClampingScrollPhysics(),
                                  onPageChanged: (index) {
                                    setState(() => currentIndex = index);
                                  },
                                  children: [
                                    HomeScreen(
                                      timeText: timeText,
                                      onPracticeTap: () => _changeTab(2),
                                      onLessonsTap: () => _changeTab(1),
                                      onStoryTap: () => _changeTab(3),
                                    ),
                                    LessonsScreen(
                                      onTabChanged: _changeTab,
                                    ),
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
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        const Positioned(left: 50, top: 150, child: DecorativeArch()),
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
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 4,
          ),
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
  final VoidCallback onStoryTap;

  const HomeScreen({
    super.key,
    required this.timeText,
    required this.onPracticeTap,
    required this.onLessonsTap,
    required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TopBar(
          leadingText: '',
          trailing: SoftPill(text: '愿每一个手势都被看见'),
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
                const SectionTitle(
                  title: '今日旅程',
                  trailing: 'Monument Valley Mood',
                ),
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
          if (v == 3) onStoryTap();
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
  final int lane;
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
    steps: ['先看一遍示范动作', '对着镜子跟练 3 次', '进入练习页做镜头识别'],
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
    steps: ['观察起手位置', '练习向外送出的路径', '做一次完整识别反馈'],
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
    steps: ['看胸口定位点', '减少多余摆动', '完成 3 次平滑练习'],
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
    steps: ['拆开成 2 个动作段', '连接成完整短句', '进入实战练习页'],
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
    steps: ['完成前置课程', '解锁新的章节地图', '开始连续表达训练'],
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
                    final nodeWidth = math.min(
                      188.0,
                      constraints.maxWidth * 0.54,
                    );

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
                              left: _laneLeft(
                                lesson.lane,
                                constraints.maxWidth,
                                nodeWidth,
                              ),
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

  MazeRoadPainter({required this.lessons, required this.nodeWidth});

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
        colors: [Color(0xCCFFF4E6), Color(0xCCDDEEFF), Color(0xCCF6D9E8)],
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
        ..cubicTo(a.dx, midY - 45, b.dx, midY + 45, b.dx, b.dy);

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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
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
            colors: [Color(0xFFF7F0E8), Color(0xFFD9D5F8), Color(0xFFA8C8D9)],
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                      padding:
                                      const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withOpacity(
                                                0.72,
                                              ),
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
                                              padding: const EdgeInsets.only(
                                                top: 3,
                                              ),
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
      child: Transform.scale(scale: 0.82, child: const DecorativeArch()),
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
        TopBar(leadingText: '实时练习', trailing: SoftPill(text: modeText)),
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
                      const SectionTitle(
                        title: 'CV 手势识别 Demo',
                        trailing: '前端模拟版',
                        compact: true,
                      ),
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
                      const SectionTitle(
                        title: '动作反馈',
                        trailing: '给用户即时鼓励',
                        compact: true,
                      ),
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
                      SectionTitle(
                        title: '可扩展的真实功能',
                        trailing: '适合比赛答辩',
                        compact: true,
                      ),
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
                  text:
                  '1）手语识别 + 教学闭环；2）有社会关怀价值；3）手机端易落地；4）适合加入 AI 陪练、表情反馈、学习成长体系。',
                ),
                SizedBox(height: 12),
                StoryTextCard(
                  title: '后续技术路线',
                  text:
                  '前端负责摄像头采集与交互；CV 模块可用 MediaPipe Hands 提取关键点；分类模型可先做静态词汇识别，再升级到动态短句识别；最后加入教学内容管理和用户进度系统。',
                ),
                SizedBox(height: 12),
                StoryTextCard(
                  title: '一句话介绍',
                  text:
                  '一款基于计算机视觉的手机端手语教学 App，通过实时动作识别、分步示范与情境化课程，帮助更多人温柔地学会“看见彼此”。',
                ),
                SizedBox(height: 12),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Demo by Flutter · Visual mood inspired by impossible architecture and poetic calm',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0x8C2E3557),
                      ),
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
      constraints: const BoxConstraints(minHeight: 290),
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
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 22),
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
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
              height: 1.6,
              color: Color(0xFF5F678F),
            ),
          ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFF5F678F).withOpacity(0.12),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: constraints.maxWidth * 0.62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFC8B3),
                          Color(0xFFF2E099),
                          Color(0xFFA4E0D6),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── MediaPipe-style 21 手部关键点（归一化坐标，手掌朝向镜头）─────────────
const List<Offset> _kHandLandmarksBase = [
  // 0 wrist
  Offset(0.50, 0.90),
  // 1-4 thumb
  Offset(0.32, 0.82), Offset(0.18, 0.68), Offset(0.10, 0.54), Offset(0.04, 0.42),
  // 5-8 index
  Offset(0.38, 0.60), Offset(0.32, 0.40), Offset(0.30, 0.26), Offset(0.28, 0.14),
  // 9-12 middle
  Offset(0.50, 0.58), Offset(0.50, 0.38), Offset(0.50, 0.24), Offset(0.50, 0.11),
  // 13-16 ring
  Offset(0.62, 0.60), Offset(0.68, 0.40), Offset(0.70, 0.26), Offset(0.72, 0.14),
  // 17-20 pinky
  Offset(0.74, 0.64), Offset(0.82, 0.48), Offset(0.84, 0.36), Offset(0.86, 0.25),
];

// 骨骼连接对
const List<List<int>> _kHandConnections = [
  [0,1],[1,2],[2,3],[3,4],       // thumb
  [0,5],[5,6],[6,7],[7,8],       // index
  [0,9],[9,10],[10,11],[11,12],  // middle
  [0,13],[13,14],[14,15],[15,16],// ring
  [0,17],[17,18],[18,19],[19,20],// pinky
  [5,9],[9,13],[13,17],          // palm arch
];

// ─── 手部骨架 CustomPainter ───────────────────────────────────────────────
class HandSkeletonPainter extends CustomPainter {
  final List<Offset> landmarks; // 已映射到像素坐标
  final double opacity;
  final Color jointColor;
  final Color boneColor;

  HandSkeletonPainter({
    required this.landmarks,
    required this.opacity,
    this.jointColor = const Color(0xFF4FC3F7),
    this.boneColor  = const Color(0xFF81D4FA),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) return;

    // 骨骼线
    final bonePaint = Paint()
      ..color = boneColor.withOpacity(opacity * 0.80)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final conn in _kHandConnections) {
      canvas.drawLine(landmarks[conn[0]], landmarks[conn[1]], bonePaint);
    }

    // 关键点圆
    for (int i = 0; i < landmarks.length; i++) {
      final isTip = [4, 8, 12, 16, 20].contains(i);
      final r = isTip ? 5.0 : 3.5;

      canvas.drawCircle(
        landmarks[i],
        r + 2,
        Paint()..color = Colors.white.withOpacity(opacity * 0.40),
      );
      canvas.drawCircle(
        landmarks[i],
        r,
        Paint()..color = jointColor.withOpacity(opacity),
      );
    }
  }

  @override
  @override
  bool shouldRepaint(covariant HandSkeletonPainter old) =>
      old.opacity != opacity || old.landmarks != landmarks;
}

// ─── 扫描线 Painter ────────────────────────────────────────────────────────
class ScanLinePainter extends CustomPainter {
  final double progress; // 0~1 from top to bottom

  ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        const Color(0xFF4FC3F7).withOpacity(0.85),
        const Color(0xFF80DEEA).withOpacity(0.95),
        const Color(0xFF4FC3F7).withOpacity(0.85),
        Colors.transparent,
      ],
    );
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, y - 1.5, size.width, 3))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    // glow trail
    final glowPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRect(
      Rect.fromLTWH(0, math.max(0, y - 28), size.width, 30),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScanLinePainter old) => old.progress != progress;
}

// ─── 取景框角括号 Painter ─────────────────────────────────────────────────
class ViewfinderCornerPainter extends CustomPainter {
  final Color color;
  final double opacity;

  ViewfinderCornerPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const len = 22.0;
    const m = 16.0; // margin from edge

    // top-left
    canvas.drawLine(Offset(m, m + len), Offset(m, m), paint);
    canvas.drawLine(Offset(m, m), Offset(m + len, m), paint);
    // top-right
    canvas.drawLine(Offset(size.width - m - len, m), Offset(size.width - m, m), paint);
    canvas.drawLine(Offset(size.width - m, m), Offset(size.width - m, m + len), paint);
    // bottom-left
    canvas.drawLine(Offset(m, size.height - m - len), Offset(m, size.height - m), paint);
    canvas.drawLine(Offset(m, size.height - m), Offset(m + len, size.height - m), paint);
    // bottom-right
    canvas.drawLine(Offset(size.width - m - len, size.height - m), Offset(size.width - m, size.height - m), paint);
    canvas.drawLine(Offset(size.width - m, size.height - m - len), Offset(size.width - m, size.height - m), paint);
  }

  @override
  bool shouldRepaint(covariant ViewfinderCornerPainter old) => old.opacity != opacity;
}

// ─── 全功能 CV 摄像头展示框 ───────────────────────────────────────────────
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
    with TickerProviderStateMixin {
  // ── 动画控制器 ──────────────────────────────────────────────────────────
  late final AnimationController _scanCtrl;
  late final AnimationController _jitterCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _confCtrl;

  // ── CV 状态 ──────────────────────────────────────────────────────────────
  CVPhase _phase = CVPhase.idle;
  Timer? _phaseTimer;
  final _rand = math.Random();
  List<Offset> _landmarks = [];

  // ── 真实摄像头 ──────────────────────────────────────────────────────────
  CameraController? _cameraController;
  bool _cameraReady = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _jitterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _jitterCtrl.reverse();
      } else if (s == AnimationStatus.dismissed) {
        if (_phase == CVPhase.detecting || _phase == CVPhase.scanning) {
          _jitterCtrl.forward();
        }
      }
    });

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _confCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _buildLandmarks();

    // 如果外部已经标记为已开启，立即初始化
    if (widget.cameraStarted) {
      _initCamera();
    }
  }

  // ── 初始化真实摄像头 ─────────────────────────────────────────────────────
  Future<void> _initCamera() async {
    // 1. 请求权限
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() => _cameraError = '摄像头权限被拒绝，请在设置中开启');
      return;
    }

    // 2. 选择前置或后置摄像头（优先后置，识别手势更自然）
    if (_cameras.isEmpty) {
      setState(() => _cameraError = '未检测到可用摄像头');
      return;
    }
    final cam = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    // 3. 初始化控制器
    final ctrl = CameraController(
      cam,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await ctrl.initialize();
    } catch (e) {
      if (!mounted) return;
      setState(() => _cameraError = '摄像头初始化失败：$e');
      return;
    }

    if (!mounted) return;
    setState(() {
      _cameraController = ctrl;
      _cameraReady = true;
      _cameraError = null;
    });

    // 开启 CV 流程
    _startCVFlow();
  }

  void _buildLandmarks([double jitter = 0]) {
    _landmarks = _kHandLandmarksBase.map((p) {
      final dx = (p.dx + (_rand.nextDouble() - 0.5) * jitter);
      final dy = (p.dy + (_rand.nextDouble() - 0.5) * jitter);
      return Offset(dx.clamp(0.0, 1.0), dy.clamp(0.0, 1.0));
    }).toList();
  }

  @override
  void didUpdateWidget(CameraDemoBox old) {
    super.didUpdateWidget(old);
    // 外部首次触发"开始镜头"
    if (widget.cameraStarted && !old.cameraStarted) {
      _initCamera();
    }
    // 外部触发"模拟识别"（confidenceText 变化，非 Live/-- 状态）
    if (old.confidenceText != widget.confidenceText &&
        widget.confidenceText != '--' &&
        widget.confidenceText != 'Live') {
      _startCVFlow();
    }
  }

  void _startCVFlow() {
    _phaseTimer?.cancel();
    setState(() => _phase = CVPhase.scanning);
    _jitterCtrl.forward();

    _phaseTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _phase = CVPhase.detecting;
        _buildLandmarks(0.03);
      });
      _phaseTimer = Timer(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        setState(() {
          _phase = CVPhase.matched;
          _buildLandmarks(0.008);
        });
        _confCtrl.forward(from: 0);
        // 8s 后回 idle（保持摄像头画面，只重置识别状态）
        _phaseTimer = Timer(const Duration(seconds: 8), () {
          if (!mounted) return;
          setState(() => _phase = _cameraReady ? CVPhase.scanning : CVPhase.idle);
          _confCtrl.animateTo(0, duration: const Duration(milliseconds: 500));
          if (_cameraReady) _startCVFlow(); // 持续循环检测
        });
      });
    });
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _jitterCtrl.dispose();
    _pulseCtrl.dispose();
    _confCtrl.dispose();
    _phaseTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Color get _phaseColor {
    switch (_phase) {
      case CVPhase.idle: return const Color(0xFFB0BEC5);
      case CVPhase.scanning: return const Color(0xFF4FC3F7);
      case CVPhase.detecting: return const Color(0xFFFFD54F);
      case CVPhase.matched: return const Color(0xFF81C784);
    }
  }

  String get _phaseLabel {
    switch (_phase) {
      case CVPhase.idle: return '等待手势';
      case CVPhase.scanning: return '扫描中…';
      case CVPhase.detecting: return '检测关键点…';
      case CVPhase.matched: return '✓ 匹配成功';
    }
  }

  List<Offset> _mapLandmarks(Size boxSize) {
    if (_landmarks.isEmpty) _buildLandmarks();
    // 将归一化坐标映射到 box 内的一个居中区域
    const padH = 0.12, padV = 0.08;
    return _landmarks.map((p) {
      final x = (padH + p.dx * (1 - padH * 2)) * boxSize.width;
      final y = (padV + p.dy * (1 - padV * 2 - 0.16)) * boxSize.height;
      return Offset(x, y);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool showSkeleton =
        _phase == CVPhase.detecting || _phase == CVPhase.matched;
    final bool showScan =
        _phase == CVPhase.scanning || _phase == CVPhase.detecting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 主摄像框 ──────────────────────────────────────────────────
        Container(
          height: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A2540).withOpacity(0.82),
                const Color(0xFF0D1B2A).withOpacity(0.92),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _phaseColor.withOpacity(0.22),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: _phaseColor.withOpacity(0.45),
              width: 1.4,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boxSize = Size(constraints.maxWidth, constraints.maxHeight);
                final mappedLandmarks = _mapLandmarks(boxSize);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // ── 真实摄像头 or 占位背景 ─────────────────────
                    if (_cameraReady && _cameraController != null)
                      // 真实 CameraPreview（镜像前置摄像头）
                      Transform.scale(
                        scaleX: -1, // 前置摄像头左右镜像
                        child: CameraPreview(_cameraController!),
                      )
                    else if (_cameraError != null)
                      // 权限被拒/初始化失败时显示错误提示
                      Container(
                        color: const Color(0xFF0D1B2A),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.no_photography_outlined,
                                  color: Color(0xFF4FC3F7), size: 36),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  _cameraError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF81D4FA),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // 未开启摄像头时的深色占位
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1B2A3A), Color(0xFF10192B)],
                          ),
                        ),
                      ),

                    // 网格点背景（未开启摄像头时显示）
                    if (!_cameraReady)
                      CustomPaint(
                        painter: _GridDotPainter(),
                      ),

                    // 扫描线
                    if (showScan)
                      AnimatedBuilder(
                        animation: _scanCtrl,
                        builder: (_, _) => CustomPaint(
                          painter: ScanLinePainter(_scanCtrl.value),
                        ),
                      ),

                    // 手部骨架
                    if (showSkeleton)
                      AnimatedBuilder(
                        animation: _jitterCtrl,
                        builder: (_, _) {
                          final jitter = _phase == CVPhase.detecting ? 0.012 : 0.004;
                          final jitteredLandmarks = mappedLandmarks.map((p) {
                            return Offset(
                              p.dx + (_rand.nextDouble() - 0.5) * jitter * boxSize.width,
                              p.dy + (_rand.nextDouble() - 0.5) * jitter * boxSize.height,
                            );
                          }).toList();
                          return CustomPaint(
                            painter: HandSkeletonPainter(
                              landmarks: jitteredLandmarks,
                              opacity: _phase == CVPhase.matched ? 0.92 : 0.72,
                              jointColor: _phase == CVPhase.matched
                                  ? const Color(0xFF81C784)
                                  : const Color(0xFF4FC3F7),
                              boneColor: _phase == CVPhase.matched
                                  ? const Color(0xFFA5D6A7)
                                  : const Color(0xFF81D4FA),
                            ),
                          );
                        },
                      ),

                    // 取景框角括号（pulse）
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, _) => CustomPaint(
                        painter: ViewfinderCornerPainter(
                          color: _phaseColor,
                          opacity: 0.55 + _pulseCtrl.value * 0.40,
                        ),
                      ),
                    ),

                    // idle 时显示手部剪影提示
                    if (_phase == CVPhase.idle)
                      Center(
                        child: AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, _) => Opacity(
                            opacity: 0.20 + _pulseCtrl.value * 0.15,
                            child: const CameraHandArt(),
                          ),
                        ),
                      ),

                    // matched 时显示识别词标注框
                    if (_phase == CVPhase.matched)
                      Positioned(
                        top: 18,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF81C784).withOpacity(0.22),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF81C784).withOpacity(0.55),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.recognitionText.replaceFirst('识别结果：', ''),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE8F5E9),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // 底部状态栏
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Row(
                        children: [
                          // 阶段指示点
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _phaseColor,
                              boxShadow: [
                                BoxShadow(
                                  color: _phaseColor.withOpacity(0.60),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _phaseLabel,
                              key: ValueKey(_phase),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _phaseColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // 置信度
                          if (widget.confidenceText != '--')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.confidenceText,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _phaseColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // ── 置信度动画条 ─────────────────────────────────────────────
        const SizedBox(height: 10),
        _ConfidenceBar(
          controller: _confCtrl,
          phase: _phase,
          phaseColor: _phaseColor,
          label: widget.confidenceText == '--'
              ? '等待识别'
              : '置信度 ${widget.confidenceText}',
        ),

        // ── 四阶段状态步进指示 ─────────────────────────────────────
        const SizedBox(height: 10),
        _PhaseStepRow(phase: _phase),
      ],
    );
  }
}

// ─── 网格点背景 ───────────────────────────────────────────────────────────
class _GridDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.045)
      ..style = PaintingStyle.fill;
    const gap = 22.0;
    for (double x = gap; x < size.width; x += gap) {
      for (double y = gap; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridDotPainter old) => false;
}

// ─── 置信度条 Widget ─────────────────────────────────────────────────────
class _ConfidenceBar extends StatelessWidget {
  final AnimationController controller;
  final CVPhase phase;
  final Color phaseColor;
  final String label;

  const _ConfidenceBar({
    required this.controller,
    required this.phase,
    required this.phaseColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF5F678F),
              ),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _phaseHint(phase),
                key: ValueKey(phase),
                style: TextStyle(
                  fontSize: 11,
                  color: phaseColor.withOpacity(0.80),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: AnimatedBuilder(
            animation: controller,
            builder: (_, _) {
              return LinearProgressIndicator(
                value: controller.value,
                minHeight: 7,
                backgroundColor: const Color(0xFF5F678F).withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
              );
            },
          ),
        ),
      ],
    );
  }

  String _phaseHint(CVPhase p) {
    switch (p) {
      case CVPhase.idle: return '请将手放入取景框';
      case CVPhase.scanning: return '正在扫描画面…';
      case CVPhase.detecting: return '提取关键点中…';
      case CVPhase.matched: return '动作识别完成 🎉';
    }
  }
}

// ─── 四阶段步进条 ─────────────────────────────────────────────────────────
class _PhaseStepRow extends StatelessWidget {
  final CVPhase phase;

  const _PhaseStepRow({required this.phase});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (CVPhase.idle, '待机'),
      (CVPhase.scanning, '扫描'),
      (CVPhase.detecting, '检测'),
      (CVPhase.matched, '匹配'),
    ];

    return Row(
      children: steps.map((s) {
        final active = s.$1.index <= phase.index;
        final current = s.$1 == phase;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: active
                            ? _colorFor(s.$1)
                            : const Color(0xFF5F678F).withOpacity(0.14),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.$2,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: current ? FontWeight.w700 : FontWeight.w400,
                        color: active
                            ? _colorFor(s.$1)
                            : const Color(0xFF5F678F).withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
              ),
              if (s.$1 != CVPhase.matched)
                const SizedBox(width: 4),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _colorFor(CVPhase p) {
    switch (p) {
      case CVPhase.idle: return const Color(0xFFB0BEC5);
      case CVPhase.scanning: return const Color(0xFF4FC3F7);
      case CVPhase.detecting: return const Color(0xFFFFD54F);
      case CVPhase.matched: return const Color(0xFF81C784);
    }
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
          Positioned(
            left: 22,
            top: 74,
            child: RotatedBox(
              quarterTurns: 1,
              child: HandFinger(height: 56, width: 26),
            ),
          ),
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
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.65,
                    color: Color(0xFF5F678F),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E3557),
            ),
          ),
          const SizedBox(height: 10),
          Text(text, style: mutedStyle),
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
            color: primary
                ? const Color(0xFF2E3557)
                : const Color(0xFF5F678F),
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
                  color: active
                      ? Colors.white.withOpacity(0.72)
                      : Colors.transparent,
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
