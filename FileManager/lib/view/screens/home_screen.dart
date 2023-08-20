import 'dart:io';
import 'dart:ui';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../controller/files_controller.dart';
import '../../utils/const.dart';
import '../widgets/widgets.dart';
import 'package:open_file/open_file.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FilesController myController = Get.put(FilesController());
  final FilesController myControllerr = Get.put(FilesController());
  final FilesController myOpen = Get.put(FilesController());
  String searchQuery = '';
  var gotPermission = false;
  var isMoving = false;
  var isPaste = false;
  var fullScreen = false;
  var allEditFile = false;
  var isSearching = false;
  var isAnaliz = true;
  var isOzellikler = false;
  var checkboxValue = false;
  double listBoyut = 0;
  //bool newValue = false;
  late FileSystemEntity selectedFile;
  late FileSystemEntity copyfile;
  late FileSystemEntity pastefile;

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  @override
  Widget build(BuildContext context) {
    return ControlBackButton(
      controller: myController.controller,
      child: Scaffold(
        appBar: appBar(context),
        body: FileManager(
          controller: myController.controller,
          builder: (context, snapshot) {
            myController.calculateSize(snapshot);

            final List<FileSystemEntity> entities = isSearching
                ? snapshot
                    .where((element) => element.path.contains(searchQuery))
                    .toList()
                : snapshot
                    .where((element) =>
                        element.path != '/storage/emulated/0/Android')
                    .toList();

            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Visibility(
                      visible: !fullScreen,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              fullScreen = true;
                              allEditFile = false;
                              setState(() {});
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "${myController.deviceAvailableSize.toInt()} GB / ${myController.deviceTotalSize.toInt()} GB",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    Text("Kullanılan Alan",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400,
                                        )),
                                  ],
                                ),
                                CircularPercentIndicator(
                                  animateFromLastPercent: true,
                                  animation: true,
                                  animationDuration: 1200,
                                  radius: 31.0,
                                  lineWidth: 5.0,
                                  percent:
                                      myController.deviceAvailableSize.toInt() /
                                          myController.deviceTotalSize.toInt(),
                                  progressColor: orange,
                                  backgroundColor: orage2,
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Analiz Menü                 ",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    )),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text('Analiz Et'),
                                    value: checkboxValue,
                                    activeColor: Colors.green,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        checkboxValue = value!;
                                      });

                                      if (value!) {
                                        allEditFile = true;
                                      } else {
                                        allEditFile = false;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  // Dosyaları Analiz ettiğimiz kısım
                  Visibility(
                    visible: allEditFile,
                    child: Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 0),
                        itemCount: entities.length,
                        itemBuilder: (context, index) {
                          FileSystemEntity entity = entities[index];

                          return Ink(
                            color: Colors.transparent,
                            child: ListTile(
                              trailing: Visibility(
                                visible: isAnaliz,
                                child: folderSize(entity),
                              ),
                              leading: FileManager.isFile(entity)
                                  ? Card(
                                      color: yellow,
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                            "assets/3d/copy-dynamic-premium.png"),
                                      ),
                                    )
                                  : Card(
                                      color: orange,
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                            "assets/3d/folder-dynamic-color.png"),
                                      ),
                                    ),
                              title: Row(
                                children: [
                                  Text(
                                    FileManager.basename(
                                      entity,
                                      showFileExtension: true,
                                    ),
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                if (FileManager.isDirectory(entity)) {
                                  myController.controller.openDirectory(entity);
                                  isOzellikler = false;
                                  //int sortBoyut;
                                  //sortBoyut = await calculateTotalSize(entity);
                                  int ab = calculateTotalSize(entity);
                                  myController.onlySortSize();
                                  //int a = myController.onlySortSize2(ab);

                                  entities.sort((a, b) {
                                    int sizeA = calculateTotalSize(a);
                                    int sizeB = calculateTotalSize(b);
                                    return sizeA.compareTo(sizeB);
                                  });

                                  //entities.sort();
                                } else if (FileManager.isFile(entity)) {
                                  myController.controller.openFile(entity);
                                  myController.onlySortSize();
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // dosyalarda düzenleme yapılan kısım
                  Visibility(
                    visible: fullScreen,
                    child: Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 1, vertical: 0),
                        itemCount: entities.length,
                        itemBuilder: (context, index) {
                          FileSystemEntity entity = entities[index];
                          //int abc= getL
                          //String a = getLength(entity);

                          if (6 > entities.length) {
                            listBoyut = 95;
                          } else if (entities.length >= 6 &&
                              8 >= entities.length) {
                            listBoyut = 70;
                          } else if (entities.length >= 8 &&
                              11 >= entities.length) {
                            listBoyut = 55;
                          } else if (entities.length >= 11) {
                            listBoyut = 45;
                          }
                          // listBoyut = 70;
                          return Ink(
                              color: Colors.transparent,
                              child: Container(
                                width: 50,
                                height: listBoyut,
                                child: ListTile(
                                  trailing: PopupMenuButton(
                                      itemBuilder: (BuildContext context) {
                                        return <PopupMenuEntry>[
                                          PopupMenuItem(
                                            value: 'button4',
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Icon(Icons.folder_open_sharp,
                                                    color: Colors.green),
                                                const Text("Aç"),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'button5',
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Icon(Icons.copy_all,
                                                    color: Colors.green),
                                                const Text("Kopyala"),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'button3',
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Icon(Icons.move_down_rounded,
                                                    color: black),
                                                const Text("Taşı"),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'button1',
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Icon(Icons.delete,
                                                    color: orange),
                                                const Text("Sil"),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'button2',
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Icon(Icons.rotate_left_sharp,
                                                    color: yellow),
                                                const Text("İsim Değiştir"),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'button6',
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Icon(
                                                    Icons
                                                        .featured_play_list_outlined,
                                                    color: Colors.purple),
                                                const Text("Özellikler"),
                                              ],
                                            ),
                                          ),
                                        ];
                                      },
                                      onSelected: (value) async {
                                        switch (value) {
                                          case 'button1':
                                            if (FileManager.isDirectory(
                                                entity)) {
                                              await entity
                                                  .delete(recursive: true)
                                                  .then((value) {
                                                setState(() {});
                                              });
                                              ;
                                            } else {
                                              await entity
                                                  .delete()
                                                  .then((value) {
                                                setState(() {});
                                              });
                                              ;
                                            }

                                            break;
                                          case 'button2':
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                TextEditingController
                                                    renameController =
                                                    TextEditingController();
                                                return AlertDialog(
                                                  title: Text(
                                                      "Rename ${FileManager.basename(entity)}"),
                                                  content: TextField(
                                                    controller:
                                                        renameController,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text("Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        await entity
                                                            .rename(
                                                          "${myController.controller.getCurrentPath}/${renameController.text.trim()}",
                                                        )
                                                            .then((value) {
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {});
                                                        });
                                                      },
                                                      child:
                                                          const Text("Rename"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            break;
                                          case 'button3':
                                            selectedFile = entity;

                                            setState(() {
                                              isMoving = true;
                                            });
                                            break;

                                          case 'button4':
                                            myController.controller
                                                .openFile(entity);
                                            break;

                                          case 'button5':
                                            copyfile = entity;

                                            /*copyfile = entity;
                                            myController.controller
                                                .copyFile(copyfile);
                                            pastefile = copyfile;*/

                                            setState(() {
                                              isPaste = true;
                                            });
                                            break;

                                          case 'button6':
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                    title: Text(
                                                        "${FileManager.basename(entity)}"),
                                                    content: Container(
                                                      width: 120.0,
                                                      height: 120.0,
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                      16.0)),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  "Dosya Boyutu:  "),
                                                              Container(
                                                                  child: folderSize(
                                                                      entity)),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  'Dosyanın Uzantısı:  '),
                                                              Container(
                                                                child: fileEx(
                                                                    entity),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  'Oluşturma Tarihi:  '),
                                                              Container(
                                                                child:
                                                                    subtitle4(
                                                                        entity),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  'Klasör İçeriği:  '),
                                                              Container(
                                                                child:
                                                                    getLength(
                                                                        entity),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ));
                                              },
                                            );

                                            setState(() {
                                              //isOzellikler = true;
                                            });
                                            break;
                                        }
                                      },
                                      child: const Icon(Icons.more_vert)),
                                  leading: FileManager.isFile(entity)
                                      ? Card(
                                          color: yellow,
                                          elevation: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                                "assets/3d/copy-dynamic-premium.png"),
                                          ),
                                        )
                                      : Card(
                                          color: orange,
                                          elevation: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                                "assets/3d/folder-dynamic-color.png"),
                                          ),
                                        ),
                                  title: Text(
                                    FileManager.basename(
                                      entity,
                                      showFileExtension: true,
                                    ),
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  /*subtitle: folderSize(
                                    entity,
                                  ),*/
                                  onTap: () async {
                                    if (FileManager.isDirectory(entity)) {
                                      myController.controller
                                          .openDirectory(entity);
                                      isOzellikler = false;
                                    } else if (FileManager.isFile(entity)) {
                                      myController.controller.openFile(entity);
                                      /* setState(() {
                                    isOzellikler = false;
                                  });*/
                                    }
                                  },
                                ),
                              ));
                        },
                      ),
                    ),
                  ),
                  // dosyada analizin sonuçlandığı kısım
                  //Visibility(child: child),
                ],
              ),
            );
          },
        ),
        floatingActionButton: gotPermission == false
            ? FloatingActionButton.extended(
                onPressed: () async {
                  await getPermission();
                },
                label: const Text("Request File Access Permission"),
              )
            : null,
      ),
    );
  }

  Future<void> getPermission() async {
    if (await Permission.storage.request().isGranted &&
        await Permission.accessMediaLocation.request().isGranted &&
        await Permission.manageExternalStorage.request().isGranted) {
      gotPermission = true;
      setState(() {});
    } else {
      await Permission.storage.request().then((value) {
        if (value.isGranted) {
          setState(() {
            gotPermission = true;
          });
        }
      });
    }
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      actions: [
        Visibility(
            visible: isPaste,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  myController.controller.copyFile(copyfile);
                  /*copyfile.rename(
                      "${myController.controller.getCurrentPath}/${FilesController.dosyap(copyfile, pastefile)}");*/
                  setState(() {
                    isPaste = false;
                  });
                },
                child: Row(
                  children: const [
                    Text("Yapıştır ",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Icon(Icons.paste),
                  ],
                ),
              ),
            )),
        Visibility(
            visible: isMoving,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  selectedFile.rename(
                      "${myController.controller.getCurrentPath}/${FileManager.basename(selectedFile)}");
                  setState(() {
                    isMoving = false;
                  });
                },
                child: Row(
                  children: const [
                    Text("Move here ",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Icon(Icons.paste),
                  ],
                ),
              ),
            )),
        Visibility(
          visible: !isMoving && !isPaste,
          child: PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 'button1',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.folder_open, color: orange),
                        const Text("Yeni Klasör"),
                      ],
                    ),
                  ),
                ];
              },
              onSelected: (value) {
                switch (value) {
                  case 'button1':
                    myController.createFolder(context);

                    break;
                }
              },
              child: const Icon(Icons.create_new_folder_outlined)),
        ),
        Visibility(
          visible: !isMoving,
          child: IconButton(
            onPressed: () => myController.sort(context),
            icon: const Icon(Icons.sort_rounded),
          ),
        ),
      ],
      title: const Text("Dosya Yöneticisi",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          await myController.controller.goToParentDirectory().then((value) {
            if (myController.controller.getCurrentPath ==
                "/storage/emulated/0") {
              fullScreen = false;
              allEditFile = false;
              isAnaliz = true;
              setState(() {});
            }
          });
        },
      ),
    );
  }
}

class Property extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Open Dialog'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Dialog Title'),
                  content: Text('This is the content of the dialog.'),
                  actions: [
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
  /*Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Stack(
        children: [
          // Arkaplanı blurlaştırmak için BackdropFilter kullanıyoruz.
          BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 30,
                sigmaY:
                    30), // Blur etkisi için sigma değerlerini ayarlayabilirsiniz.
            child: Container(
              color: Colors.black.withOpacity(
                  0.1), // Blurlanan arka planın opaklık değerini ayarlayabilirsiniz.
              constraints: BoxConstraints.expand(),
            ),
          ),
          Center(
            child: ElevatedButton(
              child: Text('Go Back'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Visibility(
              visible: true,
              child: Expanded(
                flex: 1,
                child: Container(
                  height: 200,
                  color: Colors.green,
                  child: const Center(
                    child: Text('expanded'),
                  ),
                ),
              )),
        ],
      ),
    );
  }*/
}
