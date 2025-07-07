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

  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _workTimer?.cancel();
    super.dispose();
  }

  void _toggleWorkMode() {
    setState(() {
      _isWorkMode = !_isWorkMode;
    });

    if (_isWorkMode) {
      _startWorkSession();
      _fadeController.forward();
      _slideController.forward();
      HapticFeedback.mediumImpact();
    } else {
      _stopWorkSession();
      _fadeController.reverse();
      _slideController.reverse();
      HapticFeedback.lightImpact();
    }
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

          // Toggle Button
          GestureDetector(
            onTap: _toggleWorkMode,
            child: Container(
              width: 200,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'START FOCUS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
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

            // Stop Button
            GestureDetector(
              onTap: _toggleWorkMode,
              child: Container(
                width: 160,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.red,
                    width: 2,
                  ),
                  color: Colors.red.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    'STOP FOCUS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      letterSpacing: 1.2,
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