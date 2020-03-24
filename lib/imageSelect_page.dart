import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'preview_page.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageSelectPage extends StatefulWidget {
  ImageSelectPage({Key key}) : super(key: key);

  @override
  _ImageSelectPageState createState() => _ImageSelectPageState();
}

class _ImageSelectPageState extends State<ImageSelectPage> {
  CameraController cameraController;
  List cameras;
  int selectedCameraIndex;
  String imagePath;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        setState(() {
          // 2
          selectedCameraIndex = 0;
        });

        _initCameraController(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        print("No camera available");
      }
    }).catchError((err) {
      // 3
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController.dispose();
    }

    // 3
    cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    // 4
    cameraController.addListener(() {
      // 5
      if (mounted) {
        setState(() {});
      }

      if (cameraController.value.hasError) {
        print('Camera error ${cameraController.value.errorDescription}');
      }
    });

    // 6
    try {
      await cameraController.initialize();
    } on CameraException catch (error) {
      print(error);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _cameraPreviewWidget() {
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(
            Color(0xfff79c4f),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: CameraPreview(cameraController),
    );
  }

  Widget _cameraToggleWidget() {
    if (cameras == null || cameras.isEmpty) {
      return null;
    }
    return CupertinoButton(
      child: Icon(
        CupertinoIcons.switch_camera,
        color: CupertinoColors.inactiveGray,
        size: 50,
      ),
      onPressed: _onSwitchCamera,
    );
  }

  void _onSwitchCamera() {
    selectedCameraIndex =
        selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    _initCameraController(selectedCamera);
  }

  void _onCapturePressed(context) async {
    String path;
    try {
      path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now().toIso8601String()}.jpg', // toIso method ABSOLUTELY NECESSARY; fix found here https://github.com/btastic/flutter_native_image/issues/47
      );
      await cameraController.takePicture(path);
      final croppedPath = await _resizePhoto(path);
      _showConfirmation(context, croppedPath);
    } catch (e) {
      print(e);
    }
  }

  Future _getImage(BuildContext context) async {
    File image;
    String path;
    try {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
      path = await _resizePhoto(image.path);
      if (image != null) {
        _showConfirmation(context, path);
      }
    } catch (error) {
      print(error);
    }
  }

  Future<String> _resizePhoto(String filePath) async {
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(filePath);

    int width = properties.width;
    var offset = (properties.height - properties.width) / 2;

    final croppedFilePath = join(
        (await getTemporaryDirectory()).path,
        (await FlutterNativeImage.cropImage(
                filePath, 0, offset.round(), width, width))
            .path);
    return croppedFilePath;
  }

  void _showConfirmation(BuildContext context, String path) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            actions: <Widget>[
              CupertinoButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  File(path)
                      .delete(); // delete cropped image since user canceled
                  Navigator.of(context).pop();
                },
              ),
              CupertinoButton(
                child: Text(
                  "Continue",
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => PreviewPage(
                        imagePath: path,
                      ),
                    ),
                  );
                },
              ),
            ],
            content: Image.file(
              File(path),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Color _mainColor = Color(0xfff79c4f);
    final double width = MediaQuery.of(context).size.width;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        middle: Text(
          "Photo",
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: width,
              height: width,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(
                      color: CupertinoColors.black,
                      width: width,
                      height: (cameraController != null &&
                              cameraController.value.isInitialized)
                          ? width / cameraController.value.aspectRatio
                          : width,
                      child: cameraController == null
                          ? Text("Loading")
                          : _cameraPreviewWidget(),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CupertinoButton(
                              child: Icon(
                                Icons.filter,
                                color: CupertinoColors.inactiveGray,
                                size: 30,
                              ),
                              onPressed: () async {
                                await _getImage(context);
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: CupertinoButton(
                              child: Icon(
                                CupertinoIcons.circle,
                                color: _mainColor,
                                size: 70,
                              ),
                              onPressed: () {
                                _onCapturePressed(context);
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _cameraToggleWidget(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
