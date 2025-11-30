import 'package:flutter/material.dart';
import 'dart:async';
import 'styles.dart';

// ✅ CORRECCIÓN: Definición del enum PomodoroState
enum PomodoroState { work, shortBreak, longBreak }

class PomodoroTab extends StatefulWidget {
  const PomodoroTab({super.key});

  @override
  State<PomodoroTab> createState() => _PomodoroTabState();
}

class _PomodoroTabState extends State<PomodoroTab> {
  // Configuración del temporizador (en minutos)
  static const int workDuration = 25;
  static const int shortBreakDuration = 5;
  static const int longBreakDuration = 15;
  static const int cyclesBeforeLongBreak = 4;

  // Variables de estado
  int _currentDuration = workDuration * 60; // En segundos
  bool _isRunning = false;
  Timer? _timer;
  int _pomodoroCycles = 0;

  // Estado inicial del ciclo Pomodoro
  PomodoroState _currentState = PomodoroState.work;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- Lógica del Temporizador ---

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_currentDuration < 1) {
          _handleTimerEnd();
          timer.cancel();
        } else {
          _currentDuration--;
        }
      });
    });
  }

  void _pauseTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _pomodoroCycles = 0;
      _currentState = PomodoroState.work;
      _currentDuration = workDuration * 60;
    });
  }

  void _handleTimerEnd() {
    _isRunning = false;
    
    // Muestra una notificación/snackbar de fin de ciclo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _currentState == PomodoroState.work 
            ? '¡Tiempo de trabajo terminado! Es hora de descansar.' 
            : '¡Descanso terminado! Es hora de volver al trabajo.',
          style: const TextStyle(color: AppColors.cardColor),
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 4),
      ),
    );

    // Lógica para avanzar al siguiente estado
    if (_currentState == PomodoroState.work) {
      _pomodoroCycles++;
      if (_pomodoroCycles % cyclesBeforeLongBreak == 0) {
        _currentState = PomodoroState.longBreak;
        _currentDuration = longBreakDuration * 60;
      } else {
        _currentState = PomodoroState.shortBreak;
        _currentDuration = shortBreakDuration * 60;
      }
    } else {
      // Regresar al trabajo después de cualquier descanso
      _currentState = PomodoroState.work;
      _currentDuration = workDuration * 60;
    }
    
    // Reiniciar automáticamente el siguiente ciclo (opcional: podrías dejarlo pausado)
    _startTimer();
  }

  // --- Constructor de UI ---

  @override
  Widget build(BuildContext context) {
    // Formatear el tiempo a MM:SS
    String minutes = (_currentDuration ~/ 60).toString().padLeft(2, '0');
    String seconds = (_currentDuration % 60).toString().padLeft(2, '0');

    String statusText = _currentState == PomodoroState.work
        ? 'ENFOQUE'
        : _currentState == PomodoroState.shortBreak
            ? 'DESCANSO CORTO'
            : 'DESCANSO LARGO';
            
    Color primaryColor = _currentState == PomodoroState.work ? AppColors.primary : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título de estado
          Text(
            statusText,
            style: AppTextStyles.titleLarge.copyWith(color: primaryColor),
          ),
          Text(
            'Ciclos completados: $_pomodoroCycles',
            style: AppTextStyles.subtitle,
          ),
          
          const SizedBox(height: 40),

          // Círculo del Temporizador
          Stack(
            alignment: Alignment.center,
            children: [
              // Barra de progreso circular
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: 1 - (_currentDuration / (
                    _currentState == PomodoroState.work ? workDuration * 60 : 
                    _currentState == PomodoroState.shortBreak ? shortBreakDuration * 60 :
                    longBreakDuration * 60
                  )),
                  strokeWidth: 15,
                  backgroundColor: primaryColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              // Texto del tiempo
              Text(
                '$minutes:$seconds',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w100,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 50),

          // Botones de Control
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón Play/Pause
              FloatingActionButton(
                heroTag: 'pomodoro_play_pause',
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                backgroundColor: primaryColor,
                child: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  size: 35,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 30),
              
              // Botón Reset
              FloatingActionButton(
                heroTag: 'pomodoro_reset',
                onPressed: _resetTimer,
                backgroundColor: AppColors.background,
                elevation: 0,
                child: Icon(
                  Icons.restore,
                  size: 35,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}