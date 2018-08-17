import 'dart:ui' as ui;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:flutter_flux/flutter_flux.dart';

import 'package:http/http.dart' as http;

import 'package:gramola/model/subject.dart';

import 'package:gramola/config/connections.dart';
import 'package:gramola/config/stores.dart';

const String BACKGROUND_PHOTO = 'images/background.jpg';

class LoginTextField extends TextFormField {
  static const Color TEXT_COLOR = Colors.white;
  static const TextStyle TEXT_STYLE = TextStyle(color: TEXT_COLOR);
  LoginTextField ({
    IconData iconData,
    String labelText, 
    FormFieldValidator<String> validator, 
    FormFieldSetter<String> onSaved, 
    bool obscureText: false
    }) : super(
        decoration: new InputDecoration(
          icon: new Icon(iconData),
          labelText: labelText,
        ),
        validator: validator,
        onSaved: onSaved,
        obscureText: obscureText
      );
}

class LoginComponent extends StatefulWidget {
  @override
  _LoginComponentState createState() => new _LoginComponentState();
}

class _LoginComponentState extends State<LoginComponent>
  with StoreWatcherMixin<LoginComponent>{

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  // Never write to these stores directly. Use Actions.
  LoginStore loginStore;

  String _email;
  String _password;

  @override
  void initState() {
    super.initState();

    loginStore = listenToStore(loginStoreToken);
  }

  void _submit() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      // form is valid, let's login
      _performLogin();
    }
  }

  void _performLogin() async {
    try {
      authenticateRequestAction(_email);
      dynamic response = await http.post(Connections.loginApi, body: {"email": _email, "password": _password});
      print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        authenticateSuccessAction(Subject.fromJson(json.decode(response.body)));
      } else {
        authenticateFailureAction('Error: ' + response.statusCode);
        _showSnackbar('Authentication failed!');    
      }
      Navigator.pushNamed(scaffoldKey.currentContext, '/events?country=SPAIN&city=MADRID');
    } on PlatformException catch (e) {
      authenticateFailureAction(e.message);
      _showSnackbar('Authentication failed!');
    }
  }

  void _showSnackbar (String message) {
    final snackbar = new SnackBar(
      content: new Text(message),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Widget _buildLoginForm(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Form(
        key: formKey,
        child: new Column(
          children: [
            const Expanded(child: const SizedBox()),
            new LoginTextField(
              iconData: Icons.person,
              labelText: 'User Name',
              validator: (val) =>
              val.length < 3 ? 'Not a valid User Name' : null,
              onSaved: (val) => _email = val,
            ),
            new LoginTextField(
              iconData: Icons.vpn_key,
              labelText: 'Password',
              validator: (val) =>
              val.length < 3 ? 'Password too short.' : null,
              onSaved: (val) => _password = val,
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            new RaisedButton(
              child: new Text('Login'),
              onPressed: _submit
            ),
            const Expanded(child: const SizedBox()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      body: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Image.asset(BACKGROUND_PHOTO, fit: BoxFit.cover),
          new BackdropFilter(
            filter: new ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: new Container(
              color: Colors.black.withOpacity(0.5),
              child: _buildLoginForm(context)
            ),
          ),
        ],
      ),
    );
  }
}