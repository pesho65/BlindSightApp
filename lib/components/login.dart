import 'dart:convert';

import 'package:BlindSightApp/components/menu_drawer.dart';
import 'package:BlindSightApp/components/order_traking_page.dart';
import 'package:BlindSightApp/components/register.dart';
import 'package:BlindSightApp/utils/auth_utils.dart';
import 'package:BlindSightApp/utils/types.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Login extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return FutureBuilder(
            future: isLoggedIn(), 
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                } else {

                    String? userJSON = snapshot.data as String?;
                    User? user;

                    if (userJSON != null && userJSON.isNotEmpty) {

                        user = User.fromJson(jsonDecode(userJSON) as Map<String, dynamic>);

                        if ( user.fname!.isEmpty 
                            || user.lname!.isEmpty 
                            || user.email!.isEmpty 
                            || user.username!.isEmpty 
                            || user.password!.isEmpty ) {

                            user = null;
                            userJSON = null;

                        } else {
                            
                            Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => OrderTrackingPage())
                            );

                        }

                    }

                    return Scaffold(
                        backgroundColor: Colors.white,
                        drawer: MenuDrawer(),
                        body: Center(
                            child: ListView(
                                children: [
                                    Image.asset("assets/blindsight_logo.png"),
                                    Center(
                                        child: Text(
                                        "Login",
                                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)
                                        )
                                    ),
                                    Center(
                                        child: Column(
                                            children: [
                                                LoginForm(),
                                                ElevatedButton(
                                                    onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => Register()
                                                            )
                                                        );
                                                    },
                                                    child: Text("Create Account")
                                                )
                                            ],
                                        )
                                    )
                                ],
                            ),
                        ) 
                    );

                }
            }
        );
    }
}

class LoginForm extends StatefulWidget {

    @override
    LoginFormState createState() {
        return LoginFormState();
    }
}

class LoginFormState extends State<LoginForm> {

    // NOTE: It should be 'FormState' here!
    final _formKey = GlobalKey<FormState>();

    User user = new User();

    @override
    Widget build(BuildContext context) {
                return Form(
                    key: _formKey,
                    child: Column(
                        children: <Widget>[
                            TextFormField(
                                decoration: const InputDecoration(
                                    labelText: "Username or Email"
                                ),
                                validator: (value) {
                                    if (value == null || value.isEmpty) {
                                        return "Please enter your username or your email!";
                                    }

                                    user.username = value;
                                    return null;
                                },
                            ),
                            TextFormField(
                                decoration: const InputDecoration(
                                    labelText: "Password"
                                ),
                                validator: (value) {
                                    if (value == null || value.isEmpty) {
                                        return "Please enter a password!";
                                    }

                                    user.password = value;
                                    return null;
                                },
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                        // TODO: Add serverUrl to environment variables
                                        final serverUrl = 'http://10.0.2.2:3000/login';

                                        final request = http.MultipartRequest("POST", Uri.parse(serverUrl));
                                        request.fields["username"] = user.username!;
                                        request.fields["password"] = user.password!;

                                        final response = await request.send();

                                        authenticate(context, response);
                                    }
                                }, 
                                child: Text('Login')
                           )
                       ]
                   )
           );

        }
}
