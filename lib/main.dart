//IM_2021_012
import 'dart:math'; // Imports math functions like square root.
import 'package:flutter/material.dart'; // Imports Flutter's material design package for UI.
import 'package:math_expressions/math_expressions.dart'; // Imports math_expressions package for evaluating mathematical expressions.

void main() => runApp(MyApp()); // Runs the app, starting from the MyApp widget.

class MyApp extends StatelessWidget {
  // This is the main app widget that builds the entire app.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Removes the debug banner from the top of the app.
      title: 'Calculator', // Sets the app's title.
      theme: ThemeData(
        brightness: Brightness.light, // Sets the app's theme to light.
        scaffoldBackgroundColor:
            Colors.black, // Sets the background color to black.
      ),
      home:
          CalculatorApp(), // The home screen of the app, the CalculatorApp widget.
    );
  }
}

class CalculatorApp extends StatefulWidget {
  // This is a StatefulWidget because the state of the calculator changes (like the display and history).
  @override
  _CalculatorAppState createState() =>
      _CalculatorAppState(); // Creates the state for this widget.
}

class _CalculatorAppState extends State<CalculatorApp> {
  String _display = ''; // The expression displayed on the screen.
  bool _hasEvaluated =
      false; // Tracks if the last action was an evaluation (result shown).
  List<String> _history = []; // A list that stores the history of calculations.
  bool _showHistory = false; // Determines if the history panel is shown.

  /// This function is triggered when any button is pressed to update the display.
  void _onButtonPressed(String value) {
    setState(() {
      // If the display shows "Error", clear it when a new input is entered.
      if (_display == 'Error') {
        _display = ''; // Reset the display to an empty string.
      }

      // If a result is shown and the user presses a number, start fresh with the new value.
      if (_hasEvaluated && !_isOperator(value)) {
        _display = value; // Start a new expression with the pressed value.
        _hasEvaluated = false; // Reset the evaluation state.
        return;
      }

      // Prevent invalid inputs like leading zeros
      if (_display.isEmpty && value != '0') {
        _display = value;
      } else if (_display == '0' && value != '.') {
        // If the display is "0" and the pressed value is not ".", add the value after the 0.
        _display = '0' + value;
      } else {
        // Avoid consecutive operators (++). Replace the last operator with the new one
        if (_isOperator(value) && _isOperator(_display[_display.length - 1])) {
          _display = _display.substring(0, _display.length - 1) + value;
        } else {
          _display += value; // Otherwise, just append the value to the display.
        }
      }

      _hasEvaluated = false; // Reset the evaluation state.
    });
  }

  /// Clears the display when 'C' is pressed.
  void _onClearPressed() {
    setState(() {
      _display = ''; // Clears the display.
      _hasEvaluated = false; // Resets the evaluation state.
    });
  }

  /// Deletes the last character from the display when '⌫' is pressed.
  void _onDeletePressed() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(
            0, _display.length - 1); // Remove last character.
      } else {
        _display = ''; // If only one character is left, clear the display.
      }
    });
  }

  /// Evaluates the mathematical expression when '=' is pressed.
  void _onEqualPressed() {
    if (_display == 'Error') {
      _display = ''; // If there's an error, reset the display.
    }
    try {
      // Replace the multiplication and division symbols with valid operators for parsing.
      String input = _display.replaceAll('×', '*').replaceAll('÷', '/');

      if (input.contains('/0')) {
        // Checks if the user tries to divide by zero and throws an error
        throw Exception("Division by zero");
      }

      // Parse and evaluate the expression.
      Parser parser = Parser();
      Expression expression = parser.parse(input);
      ContextModel cm = ContextModel();
      double eval = expression.evaluate(
          EvaluationType.REAL, cm); // Evaluate the expression.

      setState(() {
        // Formats the result to remove unnecessary decimals
        String result =
            eval.toStringAsFixed(7).replaceFirst(RegExp(r'\.?0+$'), '');
        _history.insert(
            0, '$input = $result'); // Save the calculation to history.
        _display = result; // Show the result on the display.
        _hasEvaluated = true; // Mark the calculation as evaluated.
      });
    } catch (e) {
      setState(() {
        _display = 'Error'; // Show "Error" for invalid expressions.
      });
    }
  }

  /// Handles advanced operations like square root (√) and percentage (%).
  void _onAdvancedOperation(String operation) {
    if (_display == 'Error') {
      _display = ''; // Reset the display if "Error" is shown.
    }
    setState(() {
      try {
        double value =
            double.parse(_display); // Parse the current value on the display.

        String result;
        if (operation == '√') {
          // If square root is selected, calculate the square root.
          result = sqrt(value)
              .toStringAsFixed(7) //Decimal places are limited to 7
              .replaceFirst(RegExp(r'\.?0+$'), '');
        } else if (operation == '%') {
          // If percentage is selected, divide the value by 100.
          result = (value / 100)
              .toStringAsFixed(7)
              .replaceFirst(RegExp(r'\.?0+$'), '');
        } else {
          return; // Return if the operation is invalid.
        }

        _display = result; // Update the display with the result.
        _hasEvaluated = true; // Mark the operation as evaluated.
      } catch (e) {
        _display = 'Error'; // Show "Error" for invalid calculations.
      }
    });
  }

  /// Checks if the character is a math operator (+, -, ×, ÷).
  bool _isOperator(String char) {
    return ['+', '-', '×', '÷'].contains(char);
  }

  /// Toggles the visibility of the history panel.
  void _toggleHistory() {
    setState(() {
      _showHistory =
          !_showHistory; // Switch between showing and hiding the history.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // History button to toggle the history panel.
          Positioned(
            top: 40, // Position the history button at the top-right.
            right: 10,
            child: IconButton(
              icon: Icon(Icons.history,
                  color: Colors.white, size: 30.0), // History icon.
              onPressed: _toggleHistory, // Toggle history panel on click.
            ),
          ),
          if (_showHistory) // If history is visible, display the history panel.
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: 200,
              child: Container(
                color: Colors.black.withOpacity(
                    0.8), // Semi-transparent background for history.
                child: ListView.builder(
                  itemCount: _history.length, // Number of history items.
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _history[index], // Display each history item.
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ),
          // Calculator display and buttons.
          Column(
            mainAxisAlignment:
                MainAxisAlignment.end, // Align buttons at the bottom.
            children: [
              // Display area for current input or result.
              Container(
                padding: EdgeInsets.all(20.0),
                alignment: Alignment.bottomRight,
                child: SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal, // Allow horizontal scrolling.
                  reverse: true, // Scroll from right to left.
                  child: Text(
                    _display.isEmpty
                        ? ''
                        : _display, // Show the current expression.
                    style: TextStyle(
                        fontSize: 56.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              // Rows of buttons for the calculator.
              Column(
                children: [
                  _buildButtonRow(['C', '⌫', '%', '÷']),
                  _buildButtonRow(['7', '8', '9', '×']),
                  _buildButtonRow(['4', '5', '6', '-']),
                  _buildButtonRow(['1', '2', '3', '+']),
                  _buildButtonRow(['0', '.', '√', '=']),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Creates a row of buttons.
  Widget _buildButtonRow(List<String> buttons) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceEvenly, // Space buttons evenly across the row.
      children: buttons.map((buttonText) => _buildButton(buttonText)).toList(),
    );
  }

  /// Builds an individual button.
  Widget _buildButton(String buttonText) {
    bool isOperator = ['÷', '×', '-', '+', '=']
        .contains(buttonText); // Check if it's an operator.
    bool isClearOrDelete = ['C', '⌫', '%', '√']
        .contains(buttonText); // Check for clear/delete operations.

    Color buttonBackground = isOperator
        ? Color(0xFFD6BBFB) // Set background color for operators.
        : isClearOrDelete
            ? Color(
                0xFFEDE7F6) // Set background color for clear/delete buttons.
            : Colors.white; // Set background color for other buttons.

    Color textColor = isOperator
        ? Colors.purple // Set text color for operators.
        : isClearOrDelete
            ? Colors.deepPurple // Set text color for clear/delete buttons.
            : Colors.black; // Set text color for other buttons.

    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(8.0), // Add padding inside each button.
        child: ElevatedButton(
          onPressed: () {
            // Call the appropriate function based on the button text.
            if (buttonText == 'C') {
              _onClearPressed(); // Clear the display.
            } else if (buttonText == '⌫') {
              _onDeletePressed(); // Delete last character.
            } else if (buttonText == '=') {
              _onEqualPressed(); // Evaluate the expression.
            } else if (buttonText == '%' || buttonText == '√') {
              _onAdvancedOperation(buttonText); // Handle advanced operations.
            } else {
              _onButtonPressed(
                  buttonText); // Handle number/operator button press.
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackground, // Set button background color.
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(40.0), // Round button corners.
            ),
            padding: EdgeInsets.all(20.0), // Add padding inside the button.
          ),
          child: Text(
            buttonText, // Display the button's text.
            style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: textColor), // Set text style.
          ),
        ),
      ),
    );
  }
}
