import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery/Screen/display_screen.dart';

import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';

import '../database/dbmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _imageFile;

  chooseImage(ImageSource src) async {
    final pickedFile = await ImagePicker().pickImage(source: src);

    setState(
      () {
        if (pickedFile != null) {
          _imageFile = pickedFile;
          Hive.box<Gallery>('gallery').add(
            Gallery(imagePath: _imageFile?.path),
          );
        }
      },
    );
    if (_imageFile != null) {
      File(_imageFile!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 227, 227),
      appBar: AppBar(
        title: const Text('Gallery'),
        centerTitle: true,
        elevation: 10,
        backgroundColor: const Color.fromARGB(255, 33, 33, 33),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Gallery>('gallery').listenable(),
        builder: (context, Box<Gallery> box, widget) {
          List keys = box.keys.toList();
          if (keys.isEmpty) {
            return const Center(
              child: Text("Click on the 'Camera icon' to add images "),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 160,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemBuilder: (context, index) {
              List<Gallery>? data = box.values.toList();
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DisplayImage(
                        image: data[index].imagePath, index: index),
                  ));
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: const Text('Do you want to delete the image?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            data[index].delete();
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.blue,
                        width: 0.5,
                        style: BorderStyle.solid),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(
                        File(
                          data[index].imagePath!,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            itemCount: keys.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 33, 33, 33),
        onPressed: () {
          chooseImage(ImageSource.camera);
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
