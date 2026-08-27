import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('1', 'Vowels are already revealed.'),
      ('2', 'Tap a consonant you think is in the movie.'),
      ('3', 'Correct → letter appears. Wrong → lose a life.'),
      ('4', 'Strikes 6–9 unlock progressive hints.'),
      ('5', 'Guess the title before lives or timer run out.'),
    ];

    return Scaffold(
      body: MasalaBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text('HOW TO PLAY'),
                backgroundColor: Colors.transparent,
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: steps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.saffron,
                            foregroundColor: Colors.black,
                            child: Text(
                              step.$1,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              step.$2,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: PressScaleButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('GOT IT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
