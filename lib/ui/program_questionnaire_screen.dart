import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/database_provider.dart';
import '../services/program_generator.dart';
import 'forging_canvas_screen.dart';
import 'split_review_screen.dart';
import 'theme.dart';

class _AnimatedOptionCard extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _AnimatedOptionCard({
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  @override
  State<_AnimatedOptionCard> createState() => _AnimatedOptionCardState();
}

class _AnimatedOptionCardState extends State<_AnimatedOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.stop();
    _controller.animateTo(0.95,
        duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
  }

  void _onTapUp(TapUpDetails _) {
    _controller.stop();
    _controller.animateTo(1.0,
        duration: const Duration(milliseconds: 300), curve: Curves.elasticOut);
  }

  void _onTapCancel() {
    _controller.stop();
    _controller.animateTo(1.0,
        duration: const Duration(milliseconds: 300), curve: Curves.elasticOut);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class ProgramQuestionnaireScreen extends ConsumerStatefulWidget {
  const ProgramQuestionnaireScreen({super.key});

  @override
  ConsumerState<ProgramQuestionnaireScreen> createState() =>
      _ProgramQuestionnaireScreenState();
}

class _ProgramQuestionnaireScreenState
    extends ConsumerState<ProgramQuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  int _daysPerWeek = 3;
  String _experienceLevel = 'Beginner';
  String _goal = 'Hypertrophy';
  final Set<String> _targetedFocus = {};
  final Set<String> _selectedEquipment = {};
  bool _isGenerating = false;

  void _nextPage() {
    if (_currentStep < 4) {
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
      final program = await generator.generateProgram(
        daysPerWeek: _daysPerWeek,
        goal: _goal,
        experienceLevel: _experienceLevel,
        targetedFocus: _targetedFocus,
        equipment: _selectedEquipment,
      );

      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SplitReviewScreen(program: program),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating program: $e'),
            backgroundColor: GritTheme.danger,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            if (_currentStep > 0) {
              _prevPage();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: _isGenerating
            ? const ForgingCanvas()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStepIndicator(),
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
                        _buildExperienceStep(),
                        _buildGoalStep(),
                        _buildMuscleFocusStep(),
                        _buildEquipmentStep(),
                      ],
                    ),
                  ),
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
                          onPressed: (_currentStep == 4 &&
                                  _selectedEquipment.isEmpty)
                              ? null
                              : _nextPage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                          ),
                          child:
                              Text(_currentStep == 4 ? 'FINISH' : 'NEXT'),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: List.generate(5, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < 4 ? 8.0 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 8,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? GritTheme.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isCurrent
                    ? Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 10,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      )
                    : null,
              ),
            ),
          );
        }),
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
            style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }

  BoxDecoration _selectedDecoration(Color accent) {
    return BoxDecoration(
      color: accent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: accent, width: 2.5),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  BoxDecoration _unselectedDecoration() {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
    );
  }

  Widget _buildDaysStep() {
    final options = [2, 3, 4, 5];
    final optionDescs = {
      2: 'Perfect for busy schedules or starting out.',
      3: 'Classic 3-day split. Ideal balance.',
      4: 'Upper/Lower body split. Highly optimized.',
      5: 'Maximum volume for dedicated lifters.',
    };

    return _buildStepCard(
      title: 'How many days per week can you train?',
      subtitle: 'Choose your weekly frequency. Consistency is key.',
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0,
        children: options.map((val) {
          final isSelected = _daysPerWeek == val;

          return _AnimatedOptionCard(
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _daysPerWeek = val;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: isSelected
                  ? _selectedDecoration(GritTheme.primary)
                  : _unselectedDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? GritTheme.primary
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    child: Text('$val'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Days / Week',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? GritTheme.primary
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      optionDescs[val]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalStep() {
    final options = [
      ('Strength', Icons.shield, 'Focus on lifting heavier and raw power progression.'),
      ('Hypertrophy', Icons.fitness_center, 'Focus on muscle building and aesthetic definition.'),
      ('Endurance', Icons.favorite, 'Focus on high-rep work, circuit training, and muscular endurance.'),
      ('General Fitness', Icons.sports_martial_arts, 'Focus on overall conditioning, health, and balanced fitness.'),
    ];

    return _buildStepCard(
      title: 'What is your primary goal?',
      subtitle: 'This adjusts the exercise selections and template layouts.',
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (label, icon, desc) = options[index];
          final isSelected = _goal == label;

          return _AnimatedOptionCard(
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _goal = label;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: isSelected
                  ? _selectedDecoration(GritTheme.primary)
                  : _unselectedDecoration(),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? GritTheme.primary.withValues(alpha: 0.15)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? GritTheme.primary
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desc,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
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

  Widget _buildExperienceStep() {
    final options = [
      ('Beginner', Icons.child_care, 'Starting your journey with guided progressions.'),
      ('Moderate', Icons.fitness_center, 'Balanced compound and accessory work.'),
      ('Intermediate', Icons.whatshot, 'High-intensity compounds and advanced splits.'),
    ];

    return _buildStepCard(
      title: 'What is your experience level?',
      subtitle: 'This adjusts volume, complexity, and exercise selection.',
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (label, icon, desc) = options[index];
          final isSelected = _experienceLevel == label;

          return _AnimatedOptionCard(
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _experienceLevel = label;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: isSelected
                  ? _selectedDecoration(GritTheme.primary)
                  : _unselectedDecoration(),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? GritTheme.primary.withValues(alpha: 0.15)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? GritTheme.primary
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desc,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
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

  Widget _buildMuscleFocusStep() {
    final options = [
      (MuscleFocus.Chest, Icons.fitness_center, 'Pectorals — bench press variations and flyes.'),
      (MuscleFocus.Back, Icons.accessibility_new, 'Lats and rhomboids — rows and pull-ups.'),
      (MuscleFocus.Legs, Icons.directions_run, 'Quads, hamstrings, and calves.'),
      (MuscleFocus.Arms, Icons.sports_martial_arts, 'Biceps and triceps isolation work.'),
      (MuscleFocus.Shoulders, Icons.accessibility, 'Deltoids — presses and lateral raises.'),
    ];

    return _buildStepCard(
      title: 'Any muscle groups you want to prioritize?',
      subtitle: 'Optional. We will place focused muscles first in each session.',
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.2,
        children: options.map((entry) {
          final (focus, icon, desc) = entry;
          final isSelected = _targetedFocus.contains(focus.name);

          return _AnimatedOptionCard(
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _targetedFocus.remove(focus.name);
                } else {
                  _targetedFocus.add(focus.name);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: isSelected
                  ? _selectedDecoration(GritTheme.primary)
                  : _unselectedDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? GritTheme.primary.withValues(alpha: 0.15)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? GritTheme.primary
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    focus.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: isSelected
                          ? GritTheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEquipmentStep() {
    final options = [
      ('Full Gym', Icons.business, 'Access to barbells, dumbbells, cables, machines.'),
      ('Home Gym', Icons.home, 'Access to barbells, rack, dumbbells.'),
      ('Dumbbell Only', Icons.sports_gymnastics, 'Access to dumbbells only.'),
      ('Bodyweight', Icons.accessibility_new, 'No equipment — bodyweight exercises only.'),
    ];

    return _buildStepCard(
      title: 'What equipment do you have?',
      subtitle: 'Select all that apply. We will filter routines to match.',
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (label, icon, desc) = options[index];
          final isSelected = _selectedEquipment.contains(label);

          return _AnimatedOptionCard(
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedEquipment.remove(label);
                } else {
                  _selectedEquipment.add(label);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: isSelected
                  ? _selectedDecoration(GritTheme.accent)
                  : _unselectedDecoration(),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? GritTheme.accent.withValues(alpha: 0.15)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? GritTheme.accent
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desc,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isSelected ? GritTheme.accentViolet : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: isSelected
                            ? GritTheme.accent
                            : Theme.of(context).dividerColor,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
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
