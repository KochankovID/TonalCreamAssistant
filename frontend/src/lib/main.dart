import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

const String SERVER = "http://localhost:3000/image/";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tonal cream assistant',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const HomePage(),
    );
  }
}

enum ImageSourceType { gallery, camera }

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  //Go to another page
  void loadImage(BuildContext context, var type) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ImagePage(type)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.tealAccent[700],
        appBar: AppBar(
          title: const Text("Tonal Cream Assistant"),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(children: const [
              Icon(
                Icons.looks_one_outlined,
                color: Colors.white,
              ),
              Expanded(
                child: Text(
                  'Take a photo',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
            Row(children: const [
              Icon(
                Icons.looks_two_rounded,
                color: Colors.white,
              ),
              Expanded(
                child: Text(
                  'Wait for result',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
            Row(children: const [
              Icon(
                Icons.looks_3_outlined,
                color: Colors.white,
              ),
              Expanded(
                child: Text(
                  'Check recommendations',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
            Row(children: const [
              Icon(
                Icons.looks_4,
                color: Colors.white,
              ),
              Expanded(
                child: Text(
                  'Share results',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
            MaterialButton(
              color: Colors.amberAccent,
              child: const Text(
                "Load Image from Gallery",
                style:
                    TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                loadImage(context, ImageSourceType.gallery);
              },
            ),
            if (kIsWeb == false)
              MaterialButton(
                color: Colors.amberAccent,
                child: const Text(
                  "Pick Image from Camera",
                  style: TextStyle(
                      color: Colors.brown, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  loadImage(context, ImageSourceType.camera);
                },
              ),
          ],
        )));
  }
}

class ImagePage extends StatefulWidget {
  final type;
  const ImagePage(this.type, {Key? key}) : super(key: key);

  @override
  ImagePageState createState() => ImagePageState(type);
}

class ImagePageState extends State<ImagePage> {
  var _image;
  var imagePicker;
  var type;

  ImagePageState(this.type);
  void loadResultsPage(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ResultsPage()));
  }

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.tealAccent[700],
      appBar: AppBar(
          title: Text(type == ImageSourceType.camera
              ? "Image from Camera"
              : "Image from Gallery")),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 52,
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                var source = type == ImageSourceType.camera
                    ? ImageSource.camera
                    : ImageSource.gallery;
                if (kIsWeb == false) {
                  //If we use Android
                  XFile image = await imagePicker.pickImage(
                      source: source,
                      imageQuality: 50,
                      preferredCameraDevice: CameraDevice.front);
                  setState(() {
                    _image = image;
                  });
                } else {
                  //If we use web
                  var pickedFile = await FilePicker.platform.pickFiles();
                  setState(() {
                    var logoBase64 = pickedFile!.files.first.bytes;
                    _image = logoBase64!;
                  });
                }
              },
              child: Container(
                width: 300,
                height: 400,
                decoration: BoxDecoration(color: Colors.grey[350]),
                child: _image != null
                    ? kIsWeb == true
                        ? Image.memory(
                            //If we use web
                            _image,
                            fit: BoxFit.fitHeight,
                          )
                        : Image.file(
                            //If we use Android
                            File(_image.path),
                            fit: BoxFit.fitHeight,
                          )
                    : Container(
                        //If we don't chose the image
                        decoration: BoxDecoration(color: Colors.grey[350]),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          MaterialButton(
            color: Colors.amberAccent,
            child: const Text(
              "Process picture",
              style:
                  TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              //print("Pressed");
              //Send to server
              final url = Uri.parse("$SERVER");

              var request = new http.MultipartRequest("POST", url);
              request.fields['user'] = 'blah';
              if (kIsWeb == false) {
                //If we use Android
                request.files.add(await http.MultipartFile.fromPath(
                    'file', _image.path,
                    contentType: new MediaType('image', 'jpg')));
              } else {
                request.files.add(new http.MultipartFile.fromBytes(
                    'file', _image,
                    contentType: new MediaType('image', 'jpg')));
              }
              request.send().then((response) {
                if (response.statusCode == 200) print("Uploaded!");
                else print("no");
              });
              //var response = await http.post(url, body: {'name':'test','num':'10'});
             // print("Response status: ${response.statusCode}");
             // print("Response body: ${response.body}");


              loadResultsPage(context);
            },
          ),
        ],
      ),
    );
  }
}

class ResultsPage extends StatefulWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  ResultsPageState createState() => ResultsPageState();
}

class ResultsPageState extends State<ResultsPage> {
  //Go to another page
  // void loadResultsPage(BuildContext context) {
  //   Navigator.push(context,
  //       MaterialPageRoute(builder: (context) => ResultsPage()));
  // }

  ResultsPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.tealAccent[700],
      appBar: AppBar(title: const Text("Recommendations.")),
    );
  }
}
