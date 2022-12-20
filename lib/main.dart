import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_2/bottombar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BottomBar(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Stream<QuerySnapshot> users =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/alku.png'),
                    fit: BoxFit.fill,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                child: Text('Alkütagram'),
              ),
            ],
          )),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Read data from firestore',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Container(
                  height: 250,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: users,
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot,
                      ) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong.');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading');
                        }

                        final data = snapshot.requireData;

                        return ListView.builder(
                          itemCount: data.size,
                          itemBuilder: (context, index) {
                            return Text(
                                'My username is ${data.docs[index]['name']} and my PhotoUrl is ${data.docs[index]['PhotoUrl']}');
                          },
                        );
                      }),
                ),
                const Text(
                  'Enter Your Username',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                MyCustomForm()
              ],
            )),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  var name = '';
  var PhotoUrl = '';

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return Form(
      key: _formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              hintText: 'What\'s Your Username',
              labelText: 'Name',
            ),
            onChanged: (value) {
              name = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Text';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _controller2,
            decoration: const InputDecoration(
              icon: Icon(Icons.share),
              hintText: 'What\'s Your Photourl',
              labelText: 'photourl',
            ),
            onChanged: (value) {
              PhotoUrl = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter photourl';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_formkey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sending Data to Firebase'),
                    ),
                  );
                  users
                      .add({'name': name, 'PhotoUrl': PhotoUrl})
                      .then((value) => print('post added'))
                      .catchError((error) => print('Failed to post: $error'));
                }
              },
              child: Text('Submit'),
            ),
          )
        ],
      ),
    );
  }
}

class SecondRoute extends StatefulWidget {
  @override
  State<SecondRoute> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  final Stream<QuerySnapshot> users =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 10,
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/alku.png'),
                    fit: BoxFit.fill,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                child: Title(color: Colors.white, child: Text('Alkütagram')),
              )
            ],
          )),
      body: Container(
        color: Colors.blue,
        child: Container(
          child: StreamBuilder<QuerySnapshot>(
              stream: users,
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot,
              ) {
                if (snapshot.hasError) {
                  return Text('Something went wrong.');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading');
                }

                final data = snapshot.requireData;

                return ListView.builder(
                    itemCount: data.size,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(' ${data.docs[index]["name"]}'),
                        subtitle: SizedBox(
                            height: 200,
                            child: Image.network(
                              data.docs[index]["PhotoUrl"],
                              fit: BoxFit.cover,
                            )),
                      );
                    });
              }),
        ),
      ),
    );
  }
}
