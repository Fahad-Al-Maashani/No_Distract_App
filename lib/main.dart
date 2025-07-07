import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(FocusModeApp());
}

class FocusModeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Mode',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.amber,
        colorScheme: ColorScheme.dark(
          primary: Colors.amber,
          secondary: Colors.orange,
          surface: Color(0xFF161B22),
          background: Color(0xFF0D1117),
        ),
        scaffoldBackgroundColor: Color(0xFF0D1117),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
        ),
      ),
      home: FocusModeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FocusModeScreen extends StatefulWidget {
  @override
  _FocusModeScreenState createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen>
    with TickerProviderStateMixin {
  bool _isWorkMode = false;
  Timer? _workTimer;
  int _workDuration = 0;
  double _dragProgress = 0.0;
  bool _isDragging = false;

  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _toggleController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _toggleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _toggleController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _toggleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _toggleController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _toggleController.dispose();
    _workTimer?.cancel();
    super.dispose();
  }

  void _toggleWorkMode() {
    setState(() {
      _isWorkMode = !_isWorkMode;
    });

    // Play system sound - using available enum value
    // SystemSound.click is not available, so we can use haptic feedback instead
    // or remove the sound entirely. For now, using HapticFeedback.selectionClick()
    HapticFeedback.selectionClick();

    if (_isWorkMode) {
      _startWorkSession();
      _fadeController.forward();
      _slideController.forward();
      _toggleController.forward();
      HapticFeedback.mediumImpact();
    } else {
      _stopWorkSession();
      _fadeController.reverse();
      _slideController.reverse();
      _toggleController.reverse();
      HapticFeedback.lightImpact();
    }
  }

  void _onDragUpdate(DragUpdateDetails details, double containerWidth) {
    setState(() {
      _isDragging = true;
      double newProgress = details.localPosition.dx / (containerWidth - 70);
      _dragProgress = newProgress.clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    bool shouldToggle = false;

    if (!_isWorkMode && _dragProgress > 0.6) {
      shouldToggle = true;
    } else if (_isWorkMode && _dragProgress < 0.4) {
      shouldToggle = true;
    }

    if (shouldToggle) {
      _toggleWorkMode();
    }

    // Reset drag progress
    setState(() {
      _dragProgress = _isWorkMode ? 1.0 : 0.0;
    });
  }

  void _startWorkSession() {
    _workDuration = 0;
    _workTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _workDuration++;
      });
    });
  }

  void _stopWorkSession() {
    _workTimer?.cancel();
    _workDuration = 0;
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isWorkMode
                ? [Color(0xFF0D1117), Color(0xFF1C2128), Color(0xFF21262D)]
                : [Color(0xFF161B22), Color(0xFF0D1117), Color(0xFF010409)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: Colors.amber,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Focus Mode',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isWorkMode ? _buildWorkModeUI() : _buildIdleUI(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeToggle() {
    const double toggleWidth = 280;
    const double toggleHeight = 70;
    const double circleSize = 70;

    // Calculate current position based on state or drag
    double currentProgress = _isDragging ? _dragProgress : (_isWorkMode ? 1.0 : 0.0);
    double circlePosition = currentProgress * (toggleWidth - circleSize);

    return AnimatedBuilder(
      animation: _toggleAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _toggleWorkMode,
          onHorizontalDragUpdate: (details) => _onDragUpdate(details, toggleWidth),
          onHorizontalDragEnd: _onDragEnd,
          child: Container(
            width: toggleWidth,
            height: toggleHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: LinearGradient(
                colors: (_isWorkMode || (_isDragging && _dragProgress > 0.5))
                    ? [Colors.red.shade800, Colors.red.shade600]
                    : [Colors.amber.shade600, Colors.orange.shade600],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: ((_isWorkMode || (_isDragging && _dragProgress > 0.5))
                      ? Colors.red : Colors.amber).withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background text with opacity based on progress
                Center(
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: _isDragging ? 0.3 : 0.7,
                    child: Text(
                      (_isWorkMode || (_isDragging && _dragProgress > 0.5))
                          ? 'SWIPE TO STOP'
                          : 'SWIPE TO START',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                // Sliding circle that follows finger
                AnimatedPositioned(
                  duration: _isDragging ? Duration.zero : Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  left: circlePosition,
                  top: 0,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                        // Add glow effect during drag
                        if (_isDragging)
                          BoxShadow(
                            color: ((_dragProgress > 0.5) ? Colors.red : Colors.amber)
                                .withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 12,
                            offset: Offset(0, 0),
                          ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          (_isWorkMode || (_isDragging && _dragProgress > 0.5))
                              ? Icons.stop
                              : Icons.play_arrow,
                          key: ValueKey(_isWorkMode || (_isDragging && _dragProgress > 0.5)),
                          color: (_isWorkMode || (_isDragging && _dragProgress > 0.5))
                              ? Colors.red
                              : Colors.amber,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                // Animated chevrons with dynamic opacity
                if (!_isWorkMode && !_isDragging) ...[
                  Positioned(
                    left: 90,
                    top: 20,
                    child: _buildChevron(0),
                  ),
                  Positioned(
                    left: 110,
                    top: 20,
                    child: _buildChevron(200),
                  ),
                  Positioned(
                    left: 130,
                    top: 20,
                    child: _buildChevron(400),
                  ),
                ] else if (_isWorkMode && !_isDragging) ...[
                  Positioned(
                    right: 90,
                    top: 20,
                    child: _buildChevron(0, isReverse: true),
                  ),
                  Positioned(
                    right: 110,
                    top: 20,
                    child: _buildChevron(200, isReverse: true),
                  ),
                  Positioned(
                    right: 130,
                    top: 20,
                    child: _buildChevron(400, isReverse: true),
                  ),
                ],

                // Progress indicator during drag
                if (_isDragging)
                  Positioned(
                    bottom: 5,
                    left: 10,
                    right: 10,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 100),
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _dragProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white,
                          ),
                        ),
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

  Widget _buildChevron(int delay, {bool isReverse = false}) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        double opacity = (math.sin((_rotationController.value * 2 * math.pi) +
            (delay * math.pi / 600)) + 1) / 2;
        return Opacity(
          opacity: opacity * 0.6,
          child: Icon(
            isReverse ? Icons.chevron_left : Icons.chevron_right,
            color: Colors.white,
            size: 30,
          ),
        );
      },
    );
  }

  Widget _buildIdleUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Logo
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        spreadRadius: 10,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.work_outline,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 40),

          Text(
            'Ready to Focus?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Toggle work mode to start your\nproductive session',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),

          SizedBox(height: 60),

          // Elegant Swipe Toggle Button
          _buildSwipeToggle(),
        ],
      ),
    );
  }

  Widget _buildWorkModeUI() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing Work Icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.red,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.work,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 40),

            // Work Status
            Text(
              'WORK MODE ACTIVE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 2,
              ),
            ),

            SizedBox(height: 20),

            // Timer
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.grey[900],
                border: Border.all(
                  color: Colors.grey[700]!,
                  width: 1,
                ),
              ),
              child: Text(
                _formatDuration(_workDuration),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            SizedBox(height: 40),

            // Warning Messages
            _buildWarningMessage('📵', 'Stay away from social media'),
            SizedBox(height: 16),
            _buildWarningMessage('🚫', 'No endless scrolling'),
            SizedBox(height: 16),
            _buildWarningMessage('⚡', 'Focus on your work'),

            SizedBox(height: 60),

            // Elegant Swipe Toggle Button
            _buildSwipeToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningMessage(String emoji, String message) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[900]!.withOpacity(0.5),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[300],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for Home Screen (This would be implemented as a separate widget)
class FocusModeWidget extends StatelessWidget {
  final bool isWorkMode;

  const FocusModeWidget({Key? key, required this.isWorkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isWorkMode ? Colors.red[900] : Colors.grey[800],
        border: Border.all(
          color: isWorkMode ? Colors.red : Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isWorkMode ? Icons.work : Icons.work_outline,
            color: isWorkMode ? Colors.red : Colors.grey,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            isWorkMode ? 'FOCUS MODE' : 'Ready to Focus',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isWorkMode ? Colors.red : Colors.grey,
            ),
          ),
          if (isWorkMode) ...[
            SizedBox(height: 4),
            Text(
              '📵 No Social Media',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red[300],
              ),
            ),
          ],
        ],
      ),
    );
  }
}