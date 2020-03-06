
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

import '../data/connect_repository.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  static const routeName = '/auth';
  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 3000);

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Pantry Login',
      messages: LoginMessages(
        usernameHint: 'Username',
        passwordHint: 'Password',
        confirmPasswordHint: 'Confirm',
        loginButton: 'LOG IN',
        signupButton: 'REGISTER',
        goBackButton: 'GO BACK',
        confirmPasswordError: 'Passwords do not match!',
      ),
      emailValidator: (value) {
        if (value.length < 1) {
          return "Username must not be blank";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value.isEmpty) {
          return 'Please enter a password';
        }
        /*if (value.length < 8) {
          return 'Your password must contain at least 8 characters.';
          // ignore: missing_return
        }*/
        return null;
      },
      onRecoverPassword: (_) => Future(null),
      onLogin: (loginData) {
        print('Login info');
        print('E-mal: ${loginData.name.trim()}');
        print('Password: ${loginData.password}');
        return login(loginData, context);
      },
      onSubmitAnimationCompleted: () {
        return null;
      },
      onSignup: (loginData) {
        print('Signup info');
        print('E-mail: ${loginData.name.trim()}');
        print('Password: ${loginData.password}');
        return register(loginData, context);
      },
      showDebugButtons: false,
    );
  }
}
