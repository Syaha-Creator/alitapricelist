// ignore_for_file: avoid_print, use_build_context_synchronously, non_constant_identifier_names, deprecated_member_use

import 'dart:convert';

import 'package:alitapricelist/alita.dart';
import 'package:alitapricelist/url.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String email;
  String password;

  User({
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      email: parsedJson['email'].toString(),
      password: parsedJson['password'].toString(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool loading = false;
  String? email, password;
  bool _isHidePassword = true;
  TextEditingController formemail = TextEditingController();
  TextEditingController formpass = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _tooglePasswordvisible() {
    setState(() {
      _isHidePassword = !_isHidePassword;
    });
  }

  Future<User?> create() async {
    email = formemail.text.toString();
    password = formpass.text.toString();

    print(
        "url = ${URLV2}oauth/token?grant_type=password&email=${email!}&password=${password!}$Client_Andro");
    var response = await http.post(
        Uri.parse(
            "${URLV2}oauth/token?grant_type=password&email=${email!}&password=${password!}$Client_Andro"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email!,
          'password': password!,
        }));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == "invalid email dan password combination") {
        print(response.statusCode);
        Fluttertoast.showToast(
            msg: "Invalid email and password combination",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      } else {
        int id = data['id'];
        String namaAPI = data['name'];
        String emailAPI = data['email'];
        String showimage = data['image']['url'];
        String no = data['phone'].toString();
        int area = data['area_id'];
        int compny = data['company_id'];
        String token = data['access_token'];
        setState(() {
          loading = false;
          savePref(
              0, emailAPI, namaAPI, id, showimage, no, area, compny, token);
        });

        print(response.statusCode);
        print(namaAPI);
        print("result = $data");
        // Login API(Id);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Alita()),
        );
        Fluttertoast.showToast(
            msg: "Selamat Datang",
            backgroundColor: Colors.lightBlueAccent.shade400,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP);
      }

      return User.fromJson(jsonDecode(response.body));
    } else {
      Fluttertoast.showToast(
          msg: "Sorry, Alita Out of Service or Internet No Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      throw Exception(response.statusCode);
    }
  }

  savePref(int Value, String email, String nama, int id, String image,
      String hp, int ar, int company, String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      preferences.setInt("value", 0);
      preferences.setString("name", nama);
      preferences.setString("email", email);
      preferences.setInt("id", id);
      preferences.setString("image_url", image.toString());
      preferences.setString("phone", hp);
      preferences.setInt("area_id", ar);
      preferences.setString("access_token", token);
      preferences.setInt("company_id", company);
      preferences.commit();
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  getPref() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      var name = preferences.getString("name");

      if (name != null) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Alita()));
      } else {
        const Login();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Alita Pricelist,',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            Text(
              'Log in now to continue',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            )
          ],
        ),
        toolbarHeight: 100,
        flexibleSpace: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/Top.png'), fit: BoxFit.fill))),
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //Header Container
              //Body Container
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(left: 15, right: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/login.png',
                              width: 300,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFFFFFFF),
                                      blurRadius: 8.0,
                                    )
                                  ],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  )),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Email',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    validator: (e) {
                                      if (e!.isEmpty) {
                                        return "Tolong Masukkan Email Anda";
                                      }
                                      return null;
                                    },
                                    controller: formemail,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'Masukkan Email Anda',
                                      prefixIcon: const Icon(Icons.email),
                                      hintStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins',
                                        letterSpacing: 1,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    'Password',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    validator: (e) {
                                      if (e!.isEmpty) {
                                        return "Tolong Masukkan Password Anda";
                                      }
                                      return null;
                                    },
                                    controller: formpass,
                                    obscureText: _isHidePassword,
                                    decoration: InputDecoration(
                                        hintText: "Masukkan Password Anda",
                                        prefixIcon: const Icon(Icons.key),
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            _tooglePasswordvisible();
                                          },
                                          child: Icon(
                                            _isHidePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: _isHidePassword
                                                ? Colors.black
                                                : Colors.blue,
                                          ),
                                        ),
                                        hintStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 1, color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: MaterialButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          create();
                                        }
                                      },
                                      color: Colors.blueAccent,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
