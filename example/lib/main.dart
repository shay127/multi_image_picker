import 'package:flutter/material.dart';
import 'dart:async';

import 'package:multi_image_picker/multi_image_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Asset previewImage;
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Widget buildImagePreview() {
    if (previewImage == null) {
      return Container(color: Colors.white);
    }
    return Column(children: <Widget>[
      AssetThumb(
        asset: previewImage,
        width: 300,
        height: 300,
      ),
      RaisedButton(
        child: Text("Cancel"),
        onPressed: () {
          setState(() {
            previewImage = null;
          });
        },
      ),
      RaisedButton(
        child: Text("Ok"),
        onPressed: () {
          setState(() {
            previewImage = null;
            images = [previewImage];
          });
        },
      ),
      RaisedButton(
        child: Text("Add"),
        onPressed: () async {
          images = [previewImage];
          previewImage = null;
          await loadAssets();
        },
      ),
    ]);
  }

  Future<void> loadAsset() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: false,
        selectedAssets: [],
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
          autoCloseOnSelectionLimit: true,
        ),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
          autoCloseOnSelectionLimit: true,
          startInAllView: true,
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (resultList != null && resultList.length == 1) {
      setState(() {
        previewImage = resultList[0];
        _error = error;
      });
    }
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 100,
        enableCamera: false,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
        ),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Center(child: Text('Error: $_error')),
            RaisedButton(
              child: Text("Pick images"),
              onPressed: loadAsset,
            ),
            buildImagePreview(),
            Expanded(
              child: buildGridView(),
            )
          ],
        ),
      ),
    );
  }
}
