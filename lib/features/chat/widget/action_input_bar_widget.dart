import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../services/voice_recording_service.dart';
import '../services/voice_chat_service.dart';

class ActionInputBarWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final Function(Map<String, dynamic>)? onRecordingComplete;

  const ActionInputBarWidget({super.key, this.onTap, this.onRecordingComplete});

  @override
  State<ActionInputBarWidget> createState() => _ActionInputBarWidgetState();
}

class _ActionInputBarWidgetState extends State<ActionInputBarWidget> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  Timer? _timer;
  int _secondsElapsed = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    if (_isRecording) {
      _cancelRecording();
    }
    VoiceRecordingService.dispose();
    super.dispose();
  }

  Future<void> _initializeVoiceService() async {
    try {
      final initialized = await VoiceRecordingService.initialize();
      if (!initialized) {
        _showSnackBar('Voice recording initialization failed');
      }
    } catch (e) {
      print('❌ Error initializing voice service: $e');
      _showSnackBar('Failed to initialize voice recording');
    }
  }

  void _startTimer() {
    _secondsElapsed = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _startRecording() async {
    try {
      if (_isRecording) return;

      final recordingPath = await VoiceRecordingService.startRecording();
      
      if (recordingPath == null) {
        _showSnackBar('Failed to start recording. Please check permissions.');
        return;
      }

      setState(() {
        _isRecording = true;
        _currentRecordingPath = recordingPath;
        _recordingStartTime = DateTime.now();
      });
      _startTimer();
      print('✅ Recording started: $recordingPath');
    } catch (e) {
      print('❌ Error starting recording: $e');
      _showSnackBar('Error starting recording');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      _stopTimer();
      final recordingPath = await VoiceRecordingService.stopRecording();
      
      if (recordingPath == null) {
        _showSnackBar('Recording too short or failed');
        setState(() {
          _isRecording = false;
        });
        return;
      }

      if (widget.onRecordingComplete != null) {
        widget.onRecordingComplete!({
          'audioPath': recordingPath,
          'duration': _secondsElapsed,
        });
      }

      print('✅ Recording complete: $recordingPath');
    } catch (e) {
      print('❌ Error stopping recording: $e');
      _showSnackBar('Error saving recording');
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }

  Future<void> _cancelRecording() async {
    try {
      _stopTimer();
      await VoiceRecordingService.cancelRecording();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      print('❌ Error canceling recording: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffFFFAF7),
        border: Border.all(
          color: _isRecording ? Colors.red : const Color(0xFFE67E22).withOpacity(0.4),
          width: _isRecording ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Left Action: Camera/Gallery OR Cancel
          if (_isRecording)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: _cancelRecording,
              tooltip: 'Cancel Recording',
            )
          else
            InkWell(
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                await picker.pickImage(source: ImageSource.camera);
              },
              child: SvgPicture.asset('assets/camera.svg', height: 32, width: 32),
            ),

          const SizedBox(width: 12),

          // Center: Timer & Status OR Placeholder text
          Expanded(
            child: _isRecording
                ? Row(
                    children: [
                      FadeTransition(
                        opacity: _pulseController,
                        child: const Icon(Icons.circle, color: Colors.red, size: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "RECORDING... ${_formatDuration(_secondsElapsed)}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(width: 12),

          // Right Action: Toggle Mic/Stop
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: _isRecording ? _stopRecording : _startRecording,
              child: AnimatedScale(
                scale: _isRecording ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : const Color(0xFFE67E22),
                    shape: BoxShape.circle,
                    boxShadow: _isRecording
                        ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          if (!_isRecording) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                await picker.pickImage(source: ImageSource.gallery);
              },
              child: SvgPicture.asset('assets/plus.svg', height: 32, width: 32),
            ),
          ],
        ],
      ),
    );
  }
}