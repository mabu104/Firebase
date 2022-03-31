import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_firebase_test/login.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const Login(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  String downloadURL = '';
  String filePath = '';
  Future<void> listExample() async {
    firebase_storage.ListResult result =
        await firebase_storage.FirebaseStorage.instance.ref().listAll();

    result.items.forEach((firebase_storage.Reference ref) {
      print('Found file: $ref');
    });

    result.prefixes.forEach((firebase_storage.Reference ref) {
      print('Found directory: $ref');
    });
  }

  Future<void> downloadURLExample() async {
    downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('1016820.jpg')
        .getDownloadURL();
    print(downloadURL);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(imageLink: downloadURL)),
    );
  }

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    String fileName = filePath.split('/').last;
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref('images/${fileName}')
          .putFile(file);
    } on firebase_core.FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  selectFile() async {
    // final ImagePicker _picker = ImagePicker();
    // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    // // var result = await FilePicker.platform.pickFiles(allowMultiple: false);

    //  if (image != null) {
    //    filePath=image.path;
    // //   print(filePath);
    //  } else {
    //  }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
    );
    if (result != null) {
      filePath = result.files.first.path!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  selectFile();
                },
                child: Text('Add')),
            ElevatedButton(
                onPressed: () {
                  uploadFile(filePath);
                },
                child: Text('Upload')),
            ElevatedButton(
                onPressed: () {
                  downloadURLExample();
                },
                child: Text('Download'))
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.imageLink}) : super(key: key);
  final String imageLink;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.network(
        imageLink,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return const Text('');
        },
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }
}



// class MainPage extends StatelessWidget {
//   const MainPage({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: FutureBuilder(
//       future: Firebase.initializeApp(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return Login();
//         }
//         return const Center(child: CircularProgressIndicator());
//       },
//     ));
//   }
// }
