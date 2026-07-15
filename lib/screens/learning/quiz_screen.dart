import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/learning_models.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, this.quiz});

  final QuizModel? quiz;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedOption;
  int _score = 0;
  bool _finished = false;

  QuizModel get _quiz =>
      widget.quiz ??
      const QuizModel(
        id: 'sample',
        courseId: 'sample',
        title: 'Sample Quiz',
        questions: [
          QuizQuestion(
            question: 'What is 2 + 2?',
            options: ['3', '4', '5', '6'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Which planet is closest to the Sun?',
            options: ['Venus', 'Mercury', 'Earth', 'Mars'],
            correctIndex: 1,
          ),
        ],
      );

  void _submitAnswer() {
    if (_selectedOption == null) return;
    if (_selectedOption == _quiz.questions[_currentIndex].correctIndex) {
      _score++;
    }
    if (_currentIndex < _quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
    } else {
      setState(() => _finished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      final passed = (_score / _quiz.questions.length * 100) >= _quiz.passingScore;
      return Scaffold(
        appBar: AppBar(title: Text(_quiz.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 72,
                  color: passed ? AppColors.success : AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  passed ? 'Congratulations!' : 'Keep Practicing',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Score: $_score / ${_quiz.questions.length}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _quiz.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(_quiz.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _quiz.questions.length,
            backgroundColor: Colors.white24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentIndex + 1} of ${_quiz.questions.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            RadioGroup<int>(
              groupValue: _selectedOption,
              onChanged: (value) => setState(() => _selectedOption = value),
              child: Column(
                children: List.generate(question.options.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RadioListTile<int>(
                      title: Text(question.options[i]),
                      value: i,
                    ),
                  );
                }),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedOption != null ? _submitAnswer : null,
              child: Text(
                _currentIndex < _quiz.questions.length - 1
                    ? 'Next Question'
                    : 'Submit Quiz',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
