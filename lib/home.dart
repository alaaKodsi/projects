// import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature_senior_project/file_utils.dart';
import 'package:signature_senior_project/result.dart';
//import 'package:signature_senior_project/Images.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dio = Dio(BaseOptions(connectTimeout: 15000)); // ns
  late TextEditingController _controller;
  Result? signatureResult;
  String? errorMessage;
  bool showLoading = false;
  String url = '192.168.1.102:9000';

  File? imagess;

  @override
  void initState() {
    _controller = TextEditingController(text: url);
    super.initState();
  }

  void changeUrl() {
    _controller.text = url;
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Base URL',
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      url = _controller.text;
                      Navigator.pop(context); //pop close dio
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
                    child: Text('Apply'),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Colors.purple, Colors.blue])),
        ),
        title: Text(
          'Traffic Sign Detector',
          style: TextStyle(fontFamily: 'Buttonidemo', fontSize: 30),
        ),
        actions: [
          IconButton(
            onPressed: changeUrl,
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          // image
          Center(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/traffic-lights.jpg',
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
          IgnorePointer(
            ignoring: showLoading,
            child: Opacity(
              opacity: showLoading ? 0.4 : 1.0,
              child: Builder(
                builder: (context) {
                  switch (signatureResult?.signatureStatus) {
                    case SignatureStatus.verified:
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            children: [
                              imagess != null
                                  ? Image.file(
                                      imagess!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : Text(
                                      " Failed to load image, server delay , try again please",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    )
                            ],
                          ),
                          // Center(
                          //   Image.asset(signatureResult!.imageres),
                          // ),

                          // Icon(
                          //   Icons.check_circle_outline,
                          //   color: Colors.green,
                          //   size: 150,
                          // ),
                          SizedBox(height: 16),
                          Center(
                              child: Text(
                            signatureResult!.username ?? 'Unknown',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          )),
                          //Center(child: Text((signatureResult!.value*100).toString() + '%', style: TextStyle(fontWeight: FontWeight.bold),)),
                          SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.deepPurple),
                                onPressed: () => setState(() {
                                  signatureResult = null;
                                }),
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Text('GO Home'),
                                ),
                              ),
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => selectImage(),
                                    child: Text('Open Camera'),
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.deepPurple),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => selectImageG(),
                                    child: Text('Open Gallary'),
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.deepPurple),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    case SignatureStatus.unverified:
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Icon(
                          //   Icons.error_outline,
                          //   color: Colors.red,
                          //   size: 150,
                          // ),
                          SizedBox(height: 16),
                          Center(
                              child: Text(
                            signatureResult!.username ?? 'Unknown',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontFamily: ''),
                          )),
                          //Center(child: Text((signatureResult!.value*100).toString() + '%', style: TextStyle(fontWeight: FontWeight.bold),)),
                          SizedBox(height: 32),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  '( Failed to recognize image, please try again )',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 25),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.deepPurple),
                                  onPressed: () => setState(() {
                                    signatureResult = null;
                                  }),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Text('GO Home'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    default:
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Card(
                              elevation: 60,
                              shadowColor: Colors.black,
                              color: Colors.transparent,
                              child: SizedBox(
                                width: 350,
                                height: 100,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ), //SizedBox
                                      const Text(
                                        'Just select an photo to be processed by machine learning. ',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ), //Textstyle
                                      ), //Text
                                      const SizedBox(
                                        height: 10,
                                      ), //SizedBox
                                      SizedBox(
                                        width: 100,

                                        // child: ElevatedButton(
                                        //   onPressed: () => 'Null',
                                        //   style: ButtonStyle(
                                        //       backgroundColor:
                                        //       MaterialStateProperty.all(Colors.deepPurple)),
                                        //   child: Padding(
                                        //     padding: const EdgeInsets.all(4),
                                        //     child: Row(
                                        //       children: const [
                                        //         Icon(Icons.touch_app),
                                        //         Text('Visit')
                                        //       ],
                                        //     ),
                                        //   ),
                                        // ),
                                        // RaisedButton is deprecated and should not be used
                                        // Use ElevatedButton instead

                                        // child: RaisedButton(
                                        //   onPressed: () => null,
                                        //   color: Colors.green,
                                        //   child: Padding(
                                        //     padding: const EdgeInsets.all(4.0),
                                        //     child: Row(
                                        //       children: const [
                                        //         Icon(Icons.touch_app),
                                        //         Text('Visit'),
                                        //       ],
                                        //     ), //Row
                                        //   ), //Padding
                                        // ), //RaisedButton
                                      ) //SizedBox
                                    ],
                                  ), //Column
                                ), //Padding
                              ), //SizedBox
                            ),
                            // Text(
                            //   intro,
                            //   style: TextStyle(
                            //     fontFamily: 'Buttonidemo',
                            //     fontWeight: FontWeight.w500,
                            //     fontSize: 25,
                            //   ),
                            // ),
                            Expanded(
                              //space page
                              child: Center(
                                child: ElevatedButton.icon(
                                  onPressed: openSelectBottomSheet,
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.deepPurple),
                                  label: Text("Select Photo"),
                                  icon: Icon(Icons.traffic_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                  }
                },
              ),
            ),
          ),
          Center(
            child: Visibility(
              visible: showLoading,
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionOption({
    required String title,
    required IconData icon,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(top: 24),
        child: Row(
          children: <Widget>[
            Icon(icon),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  void openSelectBottomSheet() {
    final dialogView = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 32, bottom: 16),
          child: Row(
            children: <Widget>[
              Text(
                'Pick Photo',
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
        ),
        _buildActionOption(
          icon: Icons.photo,
          title: "Open Gallery",
          onTap: () async {
            final image = await openGallery(context);
            if (image != null) uploadImage(image);
          },
        ),
        _buildActionOption(
          icon: Icons.camera,
          title: "Open Camera",
          onTap: () async {
            final image = await openCamera(context);
            if (image != null) uploadImage(image);
          },
        ),
        SizedBox(height: 64),
      ],
    );

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext bottomSheetBuildContext) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: dialogView,
          ),
        );
      },
    );
  }

  void uploadImage(File image) async {
    setState(() {
      errorMessage = null;
      showLoading = true;
    });
    try {
      final response = await dio.post(
        'http://$url/api/v1/signature',
        data: FormData.fromMap({'image': await image.toMultiPart}),
      );
      print(response.data);
      if (response.statusCode == 200) {
        final result = Result.fromJson(response.data);
        if (result.status == 200) {
          signatureResult = result;
        } else {
          throw Exception();
        }
      } else {
        throw Exception();
      }
    } catch (e) {
      print('ERROR: $e');
      BotToast.showSimpleNotification(
        title: '$e',
        backgroundColor: Colors.red,
        titleStyle: TextStyle(color: Colors.white),
      );
      signatureResult = null;
      errorMessage = 'Failed to get result, please try again!';
    }
    setState(() {
      showLoading = false;
    });
  }

  Future selectImage() async {
    final imagess = await ImagePicker().pickImage(source: ImageSource.camera);
    if (imagess == null) return;
    final imageTemporary = File(imagess.path);
    setState(() => this.imagess = imageTemporary);
  }

  Future selectImageG() async {
    final imagess = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imagess == null) return;
    final imageTemporary = File(imagess.path);
    setState(() => this.imagess = imageTemporary);
  }
}

//final intro = "Just select an photo to be processed by machine learning";
