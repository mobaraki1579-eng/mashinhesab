import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart'; // کتابخانه جدید

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Offline Calculator',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String inputExpression = '';
  String historyExpression = '';

  static const Color bgColor = Color(0xFFEAF4F6);
  static const Color btnColorDefault = Color(0xFFF2EFE9);
  static const Color btnColorEquals = Color(0xFF459588);
  static const Color txtColorNumber = Color(0xFF8B5E3C);
  static const Color txtColorOperator = Color(0xFF2E6A63);
  static const Color txtColorRed = Color(0xFFC8483C);

  // *** تابع محاسبات آفلاین ***
  void calculateResult() {
    if (inputExpression.isEmpty) return;

    String finalExpression = inputExpression;
    finalExpression = finalExpression.replaceAll('×', '*');
    finalExpression = finalExpression.replaceAll('÷', '/');

    try {
      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        historyExpression = inputExpression;
        // حذف اعشار اضافی اگر عدد صحیح بود
        if (eval == eval.toInt()) {
          inputExpression = eval.toInt().toString();
        } else {
          inputExpression = eval.toString();
        }
      });
    } catch (e) {
      setState(() {
        historyExpression = inputExpression;
        inputExpression = "Error";
      });
    }
  }

  void _onBtnTap(String text) {
    setState(() {
      if (text == '=') {
        calculateResult();
      } else if (text == 'C') {
        inputExpression = '';
        historyExpression = '';
      } else if (text == '+/-') {
        if (inputExpression.isNotEmpty) {
          if (inputExpression.startsWith('-')) {
            inputExpression = inputExpression.substring(1);
          } else {
            inputExpression = '-$inputExpression';
          }
        }
      } else if (text == '()') {
        _handleParentheses();
      } else {
        // جلوگیری از تکرار عملگرها
        if (inputExpression.isNotEmpty) {
          String lastChar = inputExpression[inputExpression.length - 1];
          if (_isOperator(text) && _isOperator(lastChar)) {
            inputExpression = inputExpression.substring(0, inputExpression.length - 1) + text;
            return;
          }
        }
        inputExpression += text;
      }
    });
  }

  void _handleParentheses() {
    int openCount = '('.allMatches(inputExpression).length;
    int closeCount = ')'.allMatches(inputExpression).length;
    if (inputExpression.isEmpty || _isOperator(inputExpression[inputExpression.length - 1]) || inputExpression.endsWith('(')) {
      inputExpression += '(';
    } else if (openCount > closeCount) {
      inputExpression += ')';
    } else {
      inputExpression += '×(';
    }
  }

  bool _isOperator(String x) {
    return ['+', '-', '×', '÷', '%'].contains(x);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(historyExpression, style: TextStyle(fontSize: 30, color: txtColorNumber.withOpacity(0.5))),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(inputExpression.isEmpty ? '0' : inputExpression,
                          style: const TextStyle(fontSize: 64, color: txtColorNumber)),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.backspace_outlined, color: txtColorNumber, size: 28),
                    onPressed: () {
                      setState(() {
                        if (inputExpression.isNotEmpty) {
                          inputExpression = inputExpression.substring(0, inputExpression.length - 1);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _buildRow(['C', '()', '%', '÷'], [txtColorRed, txtColorOperator, txtColorOperator, txtColorOperator]),
                    _buildRow(['7', '8', '9', '×'], [txtColorNumber, txtColorNumber, txtColorNumber, txtColorOperator]),
                    _buildRow(['4', '5', '6', '-'], [txtColorNumber, txtColorNumber, txtColorNumber, txtColorOperator]),
                    _buildRow(['1', '2', '3', '+'], [txtColorNumber, txtColorNumber, txtColorNumber, txtColorOperator]),
                    _buildRow(['+/-', '0', '.', '='], [txtColorNumber, txtColorNumber, txtColorNumber, Colors.white], isLast: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> txts, List<Color> colors, {bool isLast = false}) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (i) => _buildBtn(txts[i], colors[i], isLast && i == 3)),
      ),
    );
  }

  Widget _buildBtn(String text, Color color, bool isEquals) {
    return Container(
      margin: const EdgeInsets.all(6),
      child: Material(
        color: isEquals ? btnColorEquals : btnColorDefault,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _onBtnTap(text),
          child: Container(
            width: 72, height: 72,
            alignment: Alignment.center,
            child: Text(text, style: TextStyle(color: color, fontSize: isEquals ? 32 : 26)),
          ),
        ),
      ),
    );
  }
}
