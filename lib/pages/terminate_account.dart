import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/pages/signup.dart';
import 'package:provider/provider.dart';
import 'package:phone_app/utilities/constants.dart';
import 'package:phone_app/components/bottom_navigation_bar.dart';
import 'package:phone_app/components/main_app_background.dart';
import 'package:phone_app/provider/data_provider.dart';
import 'package:phone_app/models/user_details.dart';

import '../components/bottom_button.dart';
import '../components/dropdown_choice.dart';
import '../components/input_text_field.dart'; // Ensure you have UserDetails class correctly set up

class Terminate extends StatefulWidget {
  const Terminate({Key? key}) : super(key: key);

  @override
  TerminateState createState() => TerminateState();
}

class TerminateState extends State<Terminate> {
  int _currentIndex = 1;
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedReason;
  final TextEditingController _additionalReasonController = TextEditingController();
  final List<String> _reasons = [
    'Poor Service',
    'Found a Better Service',
    'Privacy Concerns',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserDataProvider>(context).userDetails?.id ?? "No ID Provided";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        //title: Text("Terminate Account"),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //     child: Center(child: Text(userId)),
        //   ),
        // ],
      ),
      body: CustomGradientContainerSoft(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 30.0, 0),
                child: const Center(
                  child: Text(
                    "Terminate Account",
                    style: kSubTitleOfPage,
                  ),
                ),
              ),
              SizedBox(height: 20),
              DropdownChoice(
                onChange: (String? newValue) {
                  setState(() {
                    _selectedReason = newValue!;
                  });
                },
                items: _reasons.map((reason) => DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason, style: kSimpleTextPurple),
                )).toList(),
                selectedValue: _selectedReason,
                helperText: 'Reason for Termination',
              ),
              SizedBox(height: 20),
              InputTextField(
                buttonText: 'Additional Details',
                fieldController: _additionalReasonController,
                height: 200,
              ),
              SizedBox(height: 50),
              BottomButton(
                onTap: _showConfirmDialog,
                buttonText: 'Terminate',
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(initialIndex: _currentIndex),
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Termination'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Please enter your password to confirm termination:'),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                autofocus: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _terminateAccount(_passwordController.text);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _terminateAccount(String password) async {
    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE'];
    // Fetch user ID from UserDataProvider
    final userId = Provider.of<UserDataProvider>(context, listen: false).userDetails?.id ?? "No ID Provided";

    if (userId == "No ID Provided") {
      print("User ID is not provided. Cannot terminate account.");
      return; // Exit the function if no user ID is provided
    }

    final apiUrl = '$baseURL/warehouse/$userId?password=${_passwordController.text}'; // Correct endpoint to terminate

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        //'Authorization': 'Bearer ${_passwordController.text}', // Use proper authorization
      },

    );

    if (response.statusCode == 204) { // Assuming 204 No Content for successful deletion
      _showSuccessPopup();
    } else if (response.statusCode == 403) { // Forbidden or Unauthorized
      _showErrorPopup("Incorrect password. Cannot delete account. Please try again.");
    } else {
      _showErrorPopup("Failed to terminate account: Incorrect password. Cannot delete account. Please try again.");
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Your account has been successfully deleted.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpPage(),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
