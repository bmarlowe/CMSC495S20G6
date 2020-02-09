import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart'; //make sure to look up this package before messing with this screen
import 'package:flutter/scheduler.dart' show timeDilation;
import 'fade_route.dart';
import 'home_screen.dart';
import 'Authentication/users.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 3000);

  //Future Use methods to find user name and password
  //TODO - More secure login handling that doesn't tell which is incorrect
  Future<String> _loginUser(LoginData data) {
    return Future.delayed(loginTime).then((_) {
      if (!userLoginData.containsKey(data.name) ||
          (userLoginData[data.name] != data.password)) {
        //need to replace const with API
        return 'Email Or Password does not match';
      }
      return null;
    });
  }

  Future<String> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      if (!userLoginData.containsKey(name)) {
        //need to replace const with API
        return 'Username not found';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Pantry Login',
      messages: LoginMessages(
        usernameHint: 'Username',
        passwordHint: 'Pass',
        confirmPasswordHint: 'Confirm',
        loginButton: 'LOG IN',
        signupButton: 'REGISTER',
        forgotPasswordButton: 'Forgot huh?',
        recoverPasswordButton: 'HELP ME',
        goBackButton: 'GO BACK',
        confirmPasswordError: 'Passwords do not match!',
        recoverPasswordIntro: 'Don\'t feel bad. Happens all the time.',
        recoverPasswordDescription: 'Lorem Ipsum is simply dummy text '
            'of the printing and typesetting industry',
        recoverPasswordSuccess: 'Password recovered successfully',
      ),
      //TODO - More robust form validation for login
      emailValidator: (value) {
        if (!value.contains('@') || !value.endsWith('.com')) {
          return "Email must contain '@' and end with '.com'";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value.isEmpty) {
          return 'Password is empty';
        }
        return null;
      },
      onLogin: (loginData) {
        print('Login info');
        print('E-mal: ${loginData.name}');
        print('Password: ${loginData.password}');
        return _loginUser(loginData);
      },
      onSignup: (loginData) {
        print('Signup info');
        print('E-mail: ${loginData.name}');
        print('Password: ${loginData.password}');
        return _loginUser(loginData);
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(FadePageRoute(
          builder: (context) => HomeScreen(),
        ));
      },
      onRecoverPassword: (email) {
        print('Recover password info');
        print('E-mail: $email');
        return _recoverPassword(email);
        // Show new password dialog
      },
      showDebugButtons: false,
    );
  }
}
