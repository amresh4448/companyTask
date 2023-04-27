import 'dart:convert';

import 'package:bloc_auth/bloc/bloc/auth_bloc.dart';
import 'package:bloc_auth/presentation/SignIn/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Getting the user from the FirebaseAuth Instance
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${user.email}',
        ),
        actions: [
          ElevatedButton(
            child: const Text('Sign Out'),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is UnAuthenticated) {
              // Navigate to the sign in screen when the user Signs Out
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => SignIn()),
                (route) => false,
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: _buildcurrentUser(context),
          )),
    );
  }
}

Widget _buildcurrentUser(BuildContext context) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.hasError) {
        return Text('Something went wrong');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text('Loading');
      }

      DocumentSnapshot documentSnapshot = snapshot.data!;
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      return Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              child: const Icon(Icons.person),
            ),
            ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Name : '),
                  Text(
                    "${data['name']}",
                  ),
                ],
              ),
            ),
            ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('LastName : '),
                  Text("${data['last']}"),
                ],
              ),
            ),
            ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Phone : '),
                  Text("${data['dob']}"),
                ],
              ),
            ),
            ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Date of Birth :'),
                  Text("${data['phone']}"),
                ],
              ),
            ),
            SizedBox(
              height: 350,
              child: SfPdfViewer.network(data['pdfurl']),
            ),
          ],
        ),
      );
    },
  );
}
