import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CalculatorScreen.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: QuizScreen(),
  ));
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  SharedPreferences? sharedPreferences;
  int highestScore = 0;
  int quizNumber = 1;
  int questionIndex = 0;
  int score = 0;
  bool isAnswered = false;

  int quizTimeInSeconds = 15 * 60; // 15 minutes in seconds
  int timeRemaining = 15 * 60; // Initially set to quiz time

  List<String> questions = [
    'What is the capital of France?',
    'Who painted the Mona Lisa?',
    'What is the largest planet in our solar system?',
    'How many continents are there in the world?',
    'What is the largest mammal?',
    'Which gas do plants absorb from the atmosphere?',
    'Who wrote the play "Romeo and Juliet"?',
    'What is the chemical symbol for gold?',
    'What is the largest ocean in the world?',
    'What is the tallest mountain on Earth?',
    'What is the primary function of the heart?',
    'Which planet is known as the Red Planet?',
    'What is the powerhouse of the cell?',
    'Which gas makes up the majority of Earth\'s atmosphere?',
    'In which year did Christopher Columbus discover America?',
    'Which famous scientist developed the theory of relativity?',
    'What is the largest desert in the world?',
    'How many players are there on a standard soccer team?',
    'Which element is the most abundant in the Earth',
    'Who is known as the "Father of Modern Physics"?',
  ];

  List<List<String>> options = [
    ['Paris', 'London', 'Madrid', 'Rome'],
    ['Leonardo da Vinci', 'Pablo Picasso', 'Vincent van Gogh', 'Claude Monet'],
    ['Saturn', 'Mars', 'Earth', 'Jupiter'],
    ['5', '6', '7', '8'],
    ['Elephant', 'Giraffe', 'Blue Whale', 'Hippopotamus'],
    ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Hydrogen'],
    ['William Shakespeare', 'Charles Dickens', 'Jane Austen', 'Mark Twain'],
    ['Au', 'Ag', 'Fe', 'Hg'],
    ['Pacific Ocean', 'Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean'],
    ['Mount Kilimanjaro', 'Mount Everest', 'Mount Fuji', 'Mount McKinley'],
    ['Pumping blood', 'Digesting food', 'Storing memories', 'Breathing'],
    ['Mars', 'Venus', 'Earth', 'Jupiter'],
    ['Mitochondria', 'Nucleus', 'Chloroplast', 'Ribosome'],
    ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Hydrogen'],
    ['1492', '1507', '1601', '1776'],
    ['Albert Einstein', 'Isaac Newton', 'Stephen Hawking', 'Marie Curie'],
    ['Sahara Desert', 'Arabian Desert', 'Antarctica', 'Gobi Desert'],
    ['11', '10', '9', '12'],
    ['Oxygen', 'Silicon', 'Iron', 'Aluminum'],
    ['Albert Einstein', 'Isaac Newton', 'Stephen Hawking', 'Marie Curie'],
  ];

  List<String> correctAnswers = [
    'Paris', 'Leonardo da Vinci', 'Jupiter', '7', 'Blue Whale', 'Carbon Dioxide',
    'William Shakespeare', 'Au', 'Pacific Ocean', 'Mount Everest', 'Pumping blood',
    'Mars', 'Mitochondria', 'Nitrogen', '1492', 'Albert Einstein', 'Sahara Desert', '11', 'Oxygen', 'Albert Einstein',
  ];

  List<String> selectedAnswers = [];

  void shuffleQuestionsAndOptions() {
    final random = Random();
    for (var i = questions.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);

      // Swap questions
      final tempQuestion = questions[i];
      questions[i] = questions[j];
      questions[j] = tempQuestion;

      // Swap options
      final tempOptions = options[i];
      options[i] = options[j];
      options[j] = tempOptions;

      // Swap correct answers
      final tempAnswer = correctAnswers[i];
      correctAnswers[i] = correctAnswers[j];
      correctAnswers[j] = tempAnswer;
    }
  }

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
    shuffleQuestionsAndOptions();
    startQuizTimer();
  }

  void initializeSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      highestScore = sharedPreferences?.getInt('highestScore') ?? 0;
    });
  }

  void updateHighestScore() async {
    final currentScore = await sharedPreferences?.getInt('highestScore');
    if (currentScore != null) {
      if (score > currentScore) {
        await sharedPreferences?.setInt('highestScore', score);
        setState(() {
          highestScore = score;
        });
      }
    } else {
      await sharedPreferences?.setInt('highestScore', score);
      setState(() {
        highestScore = score;
      });
    }
  }

  void checkAnswer(String selectedOption) {
    if (isAnswered) {
      return; // Prevent multiple answer selections
    }

    String correctAnswer = correctAnswers[questionIndex];
    bool isCorrect = selectedOption == correctAnswer;

    setState(() {
      selectedAnswers.add(selectedOption);
      isAnswered = true;

      if (isCorrect) {
        score++;
        sharedPreferences?.setInt('highestScore', score);
      }
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        if (questionIndex < questions.length - 1) {
          questionIndex++;
          isAnswered = false;
          timeRemaining = quizTimeInSeconds; // Reset timer for the next question
        } else {
          // Quiz completed, perform any desired actions
          timeRemaining = quizTimeInSeconds; // Reset timer for the next quiz
          shuffleQuestionsAndOptions(); // Shuffle questions and options for the next quiz
        }
      });
    });
  }

  void startQuizTimer() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        if (timeRemaining > 0) {
          timeRemaining--;
          startQuizTimer(); // Recursively call to update the timer
        } else {
          // Time's up, perform any desired actions here
          timeRemaining = quizTimeInSeconds; // Reset the timer for the next quiz
          shuffleQuestionsAndOptions(); // Shuffle questions and options for the next quiz
          // You can add actions to proceed to the next question or end the quiz
          // based on your requirements when the time is up.
        }
      });
    });
  }

  void shareScore() {
    String message =
        'I scored $score out of ${questions.length} in the quiz app!';
    Share.share(message);
  }

  void resetQuiz() {
    setState(() {
      selectedAnswers.clear();
      questionIndex = 0;
      quizNumber++;
      score = 0;
      isAnswered = false;
      timeRemaining = quizTimeInSeconds; // Reset timer for the next quiz
      shuffleQuestionsAndOptions(); // Shuffle questions and options for the next quiz
    });
  }

  void updateHighScore() {
    if (score > highestScore) {
      setState(() {
        highestScore = score;
      });
    }
  }

  String getQuizResult() {
    if (score >= 10) {
      return "Pass";
    } else {
      return "Fail";
    }
  }

  Color getResultColor() {
    if (score >= 10) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    String result = getQuizResult();
    Color resultColor = getResultColor();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal, // Change the app bar color to black
        title: Text('Quiz App'),
      ),

      body: Container(
        color: Colors.black, // Change the background color to black
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(
              'Time Remaining: ${(timeRemaining ~/ 60)}:${(timeRemaining % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Question ${questionIndex + 1}: ${questions[questionIndex]}',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options[questionIndex].length,
                itemBuilder: (context, index) {
                  bool isSelected =
                  selectedAnswers.contains(options[questionIndex][index]);
                  bool isCorrect = options[questionIndex][index] ==
                      correctAnswers[questionIndex];
                  bool showCorrectAnswer = isAnswered && isCorrect;

                  Color backgroundColor = Colors.transparent;
                  if (isSelected) {
                    backgroundColor = isCorrect ? Colors.green : Colors.red;
                  } else if (showCorrectAnswer) {
                    backgroundColor = Colors.green;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (!isSelected) {
                        checkAnswer(options[questionIndex][index]);
                      }
                    },
                    child: Container(
                      color: backgroundColor,
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Text(
                            '${String.fromCharCode(65 + index)}.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                                color: Colors.white60// Increase the font size
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            options[questionIndex][index],
                            style: TextStyle(
                              color: isSelected || showCorrectAnswer
                                  ? Colors.white
                                  : Colors.white60,
                              fontSize: 20, // Increase the font size
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 8),
            Text(
              'Score: $score / ${questions.length}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                  color: Colors.teal
              ),
            ),
            SizedBox(height: 8),
            IconButton(
              icon: Icon(Icons.share,color: Colors.tealAccent),
              onPressed: shareScore,
            ),
            IconButton(
              icon: Icon(Icons.calculate,color: Colors.cyanAccent, size: 40,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalculatorScreen()),
                );
              },
            ),
            SizedBox(height:0),
            if (selectedAnswers.contains(correctAnswers[questionIndex]))
              Text(
                'Correct Answer: ${correctAnswers[questionIndex]}',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              'Highest Score: $highestScore',
              style: TextStyle(
                fontSize: 18,

              ),
            ),
            // Display result and color signal
            Text(
              'Result: $result',
              style: TextStyle(
                color: resultColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {
          updateHighScore();
          resetQuiz();
        },
        child: Text('Next Quiz'),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.all(10),
        color: Colors.grey[300],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quiz $quizNumber',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'High Score: $highestScore',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
