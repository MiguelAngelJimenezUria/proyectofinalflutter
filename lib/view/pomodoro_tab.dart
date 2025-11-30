import 'package:flutter/material.dart';
import 'dart:async';
import 'styles.dart';

enum PomodoroState { work, shortBreak, longBreak }

class PomodoroTab extends StatefulWidget {
  const PomodoroTab({super.key});

  @override
  State<PomodoroTab> createState() => _PomodoroTabState();
}

class _PomodoroTabState extends State<PomodoroTab> {
  // Configuración del temporizador (ahora es una variable mutable para el ajuste)
  int _initialWorkDuration = 25; // En minutos
  static const int shortBreakDuration = 5;
  static const int longBreakDuration = 15;
  static const int cyclesBeforeLongBreak = 4;

  int _currentDuration = 25 * 60; // Duración actual en segundos
  bool _isRunning = false;
  Timer? _timer;
  int _pomodoroCycles = 0;
  PomodoroState _currentState = PomodoroState.work;

  // --- Lógica de Control ---

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Reinicia el temporizador al estado inicial basado en _currentState
  void _setDurationBasedOnState() {
    if (_currentState == PomodoroState.work) {
      _currentDuration = _initialWorkDuration * 60;
    } else if (_currentState == PomodoroState.shortBreak) {
      _currentDuration = shortBreakDuration * 60;
    } else {
      _currentDuration = longBreakDuration * 60;
    }
  }

  void _startTimer() {
    if (_timer != null) _timer!.cancel();
    if (_currentDuration == 0) _setDurationBasedOnState();

    setState(() {
      _isRunning = true;
    });

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
    _timer?.cancel();
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
      _setDurationBasedOnState(); // Usa la duración inicial establecida
    });
  }

  void _handleTimerEnd() {
    _isRunning = false;
    
    // Muestra una notificación/snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _currentState == PomodoroState.work ? '¡Tiempo de enfoque terminado!' : '¡Descanso terminado!',
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
      } else {
        _currentState = PomodoroState.shortBreak;
      }
    } else {
      _currentState = PomodoroState.work;
    }
    
    _setDurationBasedOnState(); // Establece la duración del nuevo estado
    _startTimer();
  }

  // --- Configuración de Duración (Nuevo) ---

  Future<void> _showDurationDialog() async {
    _pauseTimer(); // Pausar mientras se configura
    
    int tempDuration = _initialWorkDuration;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Configurar Tiempo de Enfoque (min)'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Duración actual: $tempDuration minutos'),
                  Slider(
                    value: tempDuration.toDouble(),
                    min: 5,
                    max: 60,
                    divisions: 11, // Para ir de 5 en 5 (60-5)/5 + 1
                    label: tempDuration.toString(),
                    activeColor: AppColors.primary,
                    onChanged: (double value) {
                      setState(() {
                        tempDuration = value.round();
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: AppColors.accent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Guardar', style: TextStyle(color: AppColors.primary)),
              onPressed: () {
                setState(() {
                  _initialWorkDuration = tempDuration;
                  _currentState = PomodoroState.work; // Volver al estado de trabajo
                  _setDurationBasedOnState(); // Aplicar el nuevo tiempo
                });
                _resetTimer(); // Reinicia el ciclo con el nuevo tiempo
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Constructor de UI (Modificado para centrado y estilo) ---

  @override
  Widget build(BuildContext context) {
    String minutes = (_currentDuration ~/ 60).toString().padLeft(2, '0');
    String seconds = (_currentDuration % 60).toString().padLeft(2, '0');

    String statusText = _currentState == PomodoroState.work
        ? 'ENFOQUE'
        : _currentState == PomodoroState.shortBreak
            ? 'DESCANSO CORTO'
            : 'DESCANSO LARGO';
            
    Color activeColor = _currentState == PomodoroState.work ? AppColors.primary : AppColors.accent;

    // Calcular la duración total del ciclo actual para el indicador de progreso
    int totalDuration;
    if (_currentState == PomodoroState.work) {
      totalDuration = _initialWorkDuration * 60;
    } else if (_currentState == PomodoroState.shortBreak) {
      totalDuration = shortBreakDuration * 60;
    } else {
      totalDuration = longBreakDuration * 60;
    }
    double progressValue = 1 - (_currentDuration / totalDuration);

    return Center( // ✅ CENTRADO PRINCIPAL
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrado vertical
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Título y Contador de Ciclos
            Text(
              statusText,
              style: AppTextStyles.titleLarge.copyWith(color: activeColor),
            ),
            Text(
              'Ciclos completados: $_pomodoroCycles',
              style: AppTextStyles.subtitle,
            ),
            
            const SizedBox(height: 40),

            // Círculo del Temporizador (Estilo de referencia)
            Stack(
              alignment: Alignment.center,
              children: [
                // Barra de progreso circular
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: progressValue.isNaN ? 0.0 : progressValue, // Manejo de NaN si totalDuration es 0
                    strokeWidth: 15,
                    backgroundColor: AppColors.cardColor, // Fondo más claro
                    valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                  ),
                ),
                // Texto del tiempo
                Text(
                  '$minutes:$seconds',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w200, // Fuente más delgada
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            // Botones de Control y Configuración
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón Play/Pause
                FloatingActionButton(
                  heroTag: 'pomodoro_play_pause',
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  backgroundColor: activeColor,
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
                  backgroundColor: AppColors.cardColor,
                  elevation: 0,
                  child: Icon(
                    Icons.restore,
                    size: 35,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 30),
                
                // Botón de Configuración de Tiempo (Nuevo)
                FloatingActionButton(
                  heroTag: 'pomodoro_config',
                  onPressed: _showDurationDialog,
                  backgroundColor: AppColors.cardColor,
                  elevation: 0,
                  child: const Icon(
                    Icons.settings,
                    size: 30,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}