import 'package:flutter/material.dart';
import 'package:wyrzutka/theme/colors.dart';
import 'package:wyrzutka/widgets/gutter_row.dart';

enum _StepType { previous, current, next }

class CustomStepper extends StatelessWidget {
  const CustomStepper({
    Key? key,
    required this.steps,
    required this.step,
  })  : assert(step < steps.length),
        super(key: key);

  final List<String> steps;
  final int step;

  _StepType typeForStep(int i) {
    if (i < step) {
      return _StepType.previous;
    } else if (i == step) {
      return _StepType.current;
    }
    return _StepType.next;
  }

  @override
  Widget build(BuildContext context) {
    final titleTextStyles = {
      _StepType.previous: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.black),
      _StepType.current: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.primaryDarker),
      _StepType.next: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).dividerColor),
    };

    return GutterRow(
      gutterSize: 16,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: Column(
              children: [
                AnimatedDefaultTextStyle(
                  duration: kThemeChangeDuration,
                  style: titleTextStyles[typeForStep(i)]!,
                  child: Text(
                    steps[i],
                  ),
                ),
                const SizedBox(height: 4.0),
                AnimatedContainer(
                  duration: kThemeChangeDuration,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: typeForStep(i) == _StepType.next ? Theme.of(context).dividerColor : AppColors.primaryDarker,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
