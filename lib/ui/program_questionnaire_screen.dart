import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';
import '../services/program_generator.dart';
import 'theme.dart';

class ProgramQuestionnaireScreen extends ConsumerStatefulWidget {
  const ProgramQuestionnaireScreen({super.key});

  @override
  ConsumerState<ProgramQuestionnaireScreen> createState() => _ProgramQuestionnaireScreenState();
}

class _ProgramQuestionnaireScreenState extends ConsumerState<ProgramQuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Answers
  int _daysPerWeek = 3;
  String _goal = 'Hypertrophy';
  String _equipment = 'Full Gym';
  bool _isGenerating = false;

  void _nextPage() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _generateProgram();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _generateProgram() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final db = ref.read(databaseProvider);
      final generator = ProgramGenerator(db);
      final count = await generator.generateProgram(
        daysPerWeek: _daysPerWeek,
        goal: _goal,
        equipment: _equipment,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generated $count workout templates successfully!'),
            backgroundColor: GritTheme.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating program: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GritTheme.background,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: GritTheme.primary),
            SizedBox(width: 8),
            Text('Build My Program'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_currentStep > 0) _prevPage();
            else Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: _isGenerating
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: GritTheme.primary),
                    SizedBox(height: 20),
                    Text(
                      'Assembling templates in database...',
                      style: TextStyle(color: GritTheme.textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step Indicator
                  _buildStepIndicator(),
                  
                  // Form Pages
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) {
                        setState(() {
                          _currentStep = page;
                        });
                      },
                      children: [
                        _buildDaysStep(),
                        _buildGoalStep(),
                        _buildEquipmentStep(),
                      ],
                    ),
                  ),

                  // Bottom buttons
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          OutlinedButton(
                            onPressed: _prevPage,
                            child: const Text('BACK'),
                          )
                        else
                          const SizedBox(),
                        ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          ),
                          child: Text(_currentStep == 2 ? 'FINISH' : 'NEXT'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final stepTitles = ['Training Frequency', 'Primary Goal', 'Available Equipment'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of 3',
                style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GritTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  stepTitles[_currentStep],
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: GritTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: GritTheme.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(GritTheme.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 20, color: GritTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: GritTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildDaysStep() {
    final options = [2, 3, 4, 5];
    final optionDescs = {
      2: 'Perfect for busy schedules or starting out.',
      3: 'Classic 3-day split (e.g. Push/Pull/Legs). Ideal balance.',
      4: 'Upper/Lower body split. Highly optimized frequency.',
      5: 'Push/Pull/Legs/Upper/Lower. For maximum volume.',
    };

    return _buildStepCard(
      title: 'How many days per week can you train?',
      subtitle: 'Choose your weekly frequency. Consistency is key.',
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final val = options[index];
          final isSelected = _daysPerWeek == val;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _daysPerWeek = val;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? GritTheme.primary.withValues(alpha: 0.1) : GritTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? GritTheme.primary : GritTheme.divider,
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: GritTheme.primary.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: isSelected ? GritTheme.primaryGradient : null,
                      color: isSelected ? null : GritTheme.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('$val', style: TextStyle(fontWeight: FontWeight.w900, color: isSelected ? Colors.white : GritTheme.textSecondary)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$val Days / Week',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          optionDescs[val]!,
                          style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalStep() {
    final options = ['Hypertrophy', 'Strength', 'General Fitness'];
    final optionIcons = {
      'Hypertrophy': Icons.fitness_center,
      'Strength': Icons.shield,
      'General Fitness': Icons.favorite,
    };
    final optionDescs = {
      'Hypertrophy': 'Focus on muscle building and aesthetic definition.',
      'Strength': 'Focus on lifting heavier and raw power progression.',
      'General Fitness': 'Focus on overall conditioning, health, and endurance.',
    };

    return _buildStepCard(
      title: 'What is your primary goal?',
      subtitle: 'This adjusts the exercise selections and template layouts.',
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final val = options[index];
          final isSelected = _goal == val;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _goal = val;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? GritTheme.primary.withValues(alpha: 0.1) : GritTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? GritTheme.primary : GritTheme.divider,
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: GritTheme.primary.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? GritTheme.primary.withValues(alpha: 0.15) : GritTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      optionIcons[val],
                      color: isSelected ? GritTheme.primary : GritTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          val,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          optionDescs[val]!,
                          style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEquipmentStep() {
    final options = ['Full Gym', 'Home Gym', 'Dumbbells Only'];
    final optionIcons = {
      'Full Gym': Icons.business,
      'Home Gym': Icons.home,
      'Dumbbells Only': Icons.sports_gymnastics,
    };
    final optionDescs = {
      'Full Gym': 'Access to barbells, dumbbells, cables, machines.',
      'Home Gym': 'Access to barbells, rack, dumbbells.',
      'Dumbbells Only': 'Access to dumbbells only.',
    };

    return _buildStepCard(
      title: 'What equipment do you have?',
      subtitle: 'We will filter routines to match your available gear.',
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final val = options[index];
          final isSelected = _equipment == val;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _equipment = val;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? GritTheme.accent.withValues(alpha: 0.1) : GritTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? GritTheme.accent : GritTheme.divider,
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: GritTheme.accent.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? GritTheme.accent.withValues(alpha: 0.15) : GritTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      optionIcons[val],
                      color: isSelected ? GritTheme.accent : GritTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(optionDescs[val]!, style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
