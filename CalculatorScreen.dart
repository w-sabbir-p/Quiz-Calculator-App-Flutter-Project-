import 'dart:math';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';

  void _handleButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == '=') {
        _input = _calculateResult();
      } else if (buttonText == 'AC') {
        _input = '';
      } else if (buttonText == '√') {
        _input = _calculateSquareRoot();
      } else if (buttonText == 'sin') {
        _input = 'sin(' + _input + ')';
      } else if (buttonText == 'cos') {
        _input = 'cos(' + _input + ')';
      } else if (buttonText == 'tan') {
        _input = 'tan(' + _input + ')';
      } else {
        _input += buttonText;
      }
    });
  }

  String _calculateResult() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_input);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      if (result.isNaN) {
        return 'Error';
      }
      return result.toStringAsFixed(2); 
    } catch (e) {
      return 'Error';
    }
  }

  String _calculateSquareRoot() {
    try {
      Parser p = Parser();
      Expression exp = p.parse('sqrt(' + _input + ')');
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      if (result.isNaN) {
        return 'Error';
      }
      return result.toStringAsFixed(2);
    } catch (e) {
      return 'Error';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF333333),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(32),
              alignment: Alignment.bottomRight,
              child: Text(
                _input,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  _buildButtonRow(['AC', '√', 'sin', 'cos']),
                  _buildButtonRow(['7', '8', '9', 'tan']),
                  _buildButtonRow(['4', '5', '6', '-']),
                  _buildButtonRow(['1', '2', '3', '+']),
                  _buildButtonRow(['0', '.', '=']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttonLabels) {
    return Expanded(
      child: Row(
        children: buttonLabels
            .map((label) => Expanded(child: _buildButton(label)))
            .toList(),
      ),
    );
  }

  Widget _buildButton(String buttonText) {
    return Container(
      margin: EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () => _handleButtonPressed(buttonText),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white54),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        child: Container(
          width: 60,
          height: 60,
          child: Center(
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    ),
  );
}
