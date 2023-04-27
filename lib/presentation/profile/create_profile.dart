import 'dart:convert';
import 'dart:io';

import 'package:bloc_auth/bloc/bloc/auth_bloc.dart';
import 'package:bloc_auth/presentation/Dashboard/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  // final _pdfurl = TextEditingController(text: downloadUrl);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstnameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<File> getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );
    if (result != null) {
      File file = File(result.files.single.path.toString());
      return file;
    } else {
      // User canceled the picker
      return null!;
    }
  }

  Future<String?> uploadFile(File file) async {
    String? downloadUrl;

    String fileName =
        '${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
    Reference storageReference = _storage.ref().child('files/$fileName');
    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    downloadUrl = await taskSnapshot.ref.getDownloadURL();
    print("downloadUrl $downloadUrl");
    return downloadUrl;
  }

  String? pdfurl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration_newer technologies "),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Navigating to the dashboard screen if the user is authenticated
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const Dashboard(),
              ),
            );
          }
          if (state is AuthError) {
            // Displaying the error message if the user is not authenticated
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is Loading) {
            // Displaying the loading indicator while the user is signing up
            return const Center(child: CircularProgressIndicator());
          }
          if (state is Authenticated) {
            // Displaying the sign up form if the user is not authenticated
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "ProfilePage form",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .color,
                                  minimumSize: Size.fromHeight(40),
                                ),
                                onPressed: () async {
                                  File file = await getFile();
                                  if (file != null) {
                                    pdfurl = await uploadFile(file);
                                  }
                                  validator:
                                  (value) {
                                    if (value!.isEmpty) {
                                      return 'cv  is required.';
                                    }
                                    return null;
                                  };
                                },
                                child: const Text('Upload Cv Pdf or docs'),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  // Text(pdfurl.toString()),
                                  Expanded(
                                    child: TextFormField(
                                      cursorColor: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .color,
                                      //key: const Key('passwordField'),
                                      textAlign: TextAlign.left,
                                      keyboardType: TextInputType.text,
                                      obscureText: false,
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.person,
                                        ),
                                        fillColor: Colors.white,
                                        labelText: 'First Name',
                                        hintText: 'FirstName',
                                        hintStyle: TextStyle(fontSize: 16),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0)),
                                          borderSide: BorderSide(
                                              width: 3, color: Colors.black38),
                                        ),
                                        filled: false,
                                        contentPadding: EdgeInsets.all(16),
                                      ),
                                      controller: _firstnameController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'FirstName is required.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      cursorColor: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .color,
                                      //key: const Key('lastName'),
                                      textAlign: TextAlign.left,
                                      keyboardType: TextInputType.text,
                                      obscureText: false,
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.person,
                                        ),
                                        fillColor: Colors.white,
                                        labelText: 'Last Name',
                                        hintText: 'Last Name',
                                        hintStyle: TextStyle(fontSize: 16),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0)),
                                          borderSide: BorderSide(
                                              width: 3, color: Colors.black38),
                                        ),
                                        filled: false,
                                        contentPadding: EdgeInsets.all(16),
                                      ),
                                      controller: _lastNameController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'LastName is required.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                cursorColor: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .color,
                                //key: const Key('passwordField'),
                                textAlign: TextAlign.left,
                                keyboardType: TextInputType.datetime,
                                obscureText: false,
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101));

                                  if (pickedDate != null) {
                                    print(pickedDate);
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    print(formattedDate);
                                    setState(() {
                                      _dobController.text =
                                          formattedDate; //set foratted date to TextField value.
                                    });
                                  } else {
                                    print("Date is not selected");
                                  }
                                },
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                  ),
                                  fillColor: Colors.white,
                                  labelText: 'Date of Birth',
                                  hintText: 'Date of Birth',
                                  hintStyle: TextStyle(fontSize: 16),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        width: 3, color: Colors.black38),
                                  ),
                                  filled: false,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                controller: _dobController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'dob is required.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                // key: const Key('PhoneField'),
                                maxLength: 10,
                                cursorColor: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .color,
                                decoration: const InputDecoration(
                                  counterText: "",
                                  labelText: 'Phone',
                                  isDense: true,
                                  prefixIcon: Icon(
                                    Icons.phone,
                                    size: 28,
                                  ),
                                  fillColor: Colors.white,
                                  hintText: 'Enter Phone',
                                  hintStyle: TextStyle(fontSize: 16),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        width: 3, color: Colors.black38),
                                  ),
                                  filled: false,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                autocorrect: false,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Phone is required.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _createAccount(context);
                                  },
                                  child: const Text('Sign Up'),
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
          return Container();
        },
      ),
    );
  }

  void _createAccount(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(CreateProfile(
        _firstnameController.text,
        _lastNameController.text,
        _dobController.text,
        _phoneController.text,
        pdfurl.toString(),
      ));
      sendEmail();
    }
  }
}

Future sendEmail() async {
  final user = FirebaseAuth.instance.currentUser!;

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'service_id': 'service_1iutpmg',
        'template_id': 'template_pc6hjuv',
        'user_id': 'kSpCE1vSX4Xk-dTOP',
        'template_params': {
          'from_name': 'sampleform',
          'from_email': user.email,
          'message': "Thank you for submmited",
        }
      }));
  return response.statusCode;
}
