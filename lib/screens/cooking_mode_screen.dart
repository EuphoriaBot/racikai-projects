import 'dart:async';

import 'package:flutter/material.dart';

import '../core/extensions/int_extensions.dart';
import '../core/mixins/cooking_timer_mixin.dart';
import '../models/recipe.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen>
    with CookingTimerMixin {
  int currentStep = 0;

  int elapsedSeconds = 0;

  bool isTimerRunning = false;

  StreamSubscription<int>? timerSubscription;

  void startTimer() {
    if (isTimerRunning) {
      return;
    }

    setState(() {
      isTimerRunning = true;
    });

    timerSubscription = cookingTimer(elapsedSeconds).listen((seconds) {
      if (!mounted) {
        return;
      }

      setState(() {
        elapsedSeconds = seconds;
      });
    });
  }

  Future<void> pauseTimer() async {
    await timerSubscription?.cancel();

    timerSubscription = null;

    if (!mounted) {
      return;
    }

    setState(() {
      isTimerRunning = false;
    });
  }

  Future<void> resetTimer() async {
    await timerSubscription?.cancel();

    timerSubscription = null;

    if (!mounted) {
      return;
    }

    setState(() {
      elapsedSeconds = 0;
      isTimerRunning = false;
    });
  }

  void nextStep() {
    if (currentStep < widget.recipe.instructions.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      _showCookingFinishedDialog();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void _showCookingFinishedDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle_outline_rounded, size: 48),
          title: const Text('Masakan Selesai! 🎉', textAlign: TextAlign.center),
          content: Text(
            'Kamu sudah menyelesaikan semua langkah '
            '${widget.recipe.title}.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final instructions = widget.recipe.instructions;

    final progress = (currentStep + 1) / instructions.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Mode Memasak')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.recipe.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Langkah ${currentStep + 1} '
                'dari ${instructions.length}',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),

              const SizedBox(height: 12),

              LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                borderRadius: BorderRadius.circular(20),
              ),

              const SizedBox(height: 28),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${currentStep + 1}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: colors.onPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            instructions[currentStep],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // TIMER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, color: colors.primary),

                    const SizedBox(width: 12),

                    Text(
                      elapsedSeconds.toClockFormat,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.onPrimaryContainer,
                      ),
                    ),

                    const Spacer(),

                    IconButton(
                      tooltip: isTimerRunning ? 'Pause' : 'Mulai',
                      onPressed: isTimerRunning ? pauseTimer : startTimer,
                      icon: Icon(
                        isTimerRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                    ),

                    IconButton(
                      tooltip: 'Reset',
                      onPressed: resetTimer,
                      icon: const Icon(Icons.restart_alt_rounded),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // NAVIGATION
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: currentStep == 0 ? null : previousStep,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Sebelumnya'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: FilledButton.icon(
                      onPressed: nextStep,
                      icon: Icon(
                        currentStep == instructions.length - 1
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        currentStep == instructions.length - 1
                            ? 'Selesai'
                            : 'Berikutnya',
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
