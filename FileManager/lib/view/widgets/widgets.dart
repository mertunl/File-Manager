import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import '../../utils/const.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controller/files_controller.dart';
import '../../utils/const.dart';
import 'package:file_manager_app/view/screens/home_screen.dart';

Future<void> getPermission() async {
  if (await Permission.storage.request().isGranted &&
      await Permission.accessMediaLocation.request().isGranted &&
      await Permission.manageExternalStorage.request().isGranted) {
    gotPermission = true;
    // setState(() {});
  } else {
    await Permission.storage.request().then((value) {
      if (value.isGranted) {
        /*setState(() {
            gotPermission = true;
          });*/
      }
    });
  }
}

final FilesController myController = Get.put(FilesController());
var isSearching = false;
String searchQuery = '';
var gotPermission = false;
Widget getS() => ControlBackButton(
      controller: myController.controller,
      child: Scaffold(
        //appBar: appBar(context),
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
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // dosyaların görünümü
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 0),
                      itemCount: entities.length,
                      itemBuilder: (context, index) {
                        FileSystemEntity entity = entities[index];

                        return Ink(
                          color: Colors.transparent,
                          child: ListTile(
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
                            title: Text(
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
                            subtitle: subtitle(
                              entity,
                            ),
                            onTap: () async {
                              if (FileManager.isDirectory(entity)) {
                                try {
                                  myController.controller.openDirectory(entity);
                                } catch (e) {
                                  myController.alert(
                                      context, "Enable to open this folder");
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
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

Widget storagePercentWidget(int totalStorage,
        int usedStorage) => /*InkWell(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${usedStorage} GB / $totalStorage GB",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  )),
              Text("Used Storage",
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
            percent: usedStorage / totalStorage,
            progressColor: orange,
            backgroundColor: orage2,
          )
        ],
      ),
    );*/

    InkWell(
      //height: 18.h,
      /*decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.grey, width: 0.5),
      ),*/
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${usedStorage} GB / $totalStorage GB",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  )),
              Text("Used Storage",
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
            percent: usedStorage / totalStorage,
            progressColor: orange,
            backgroundColor: orage2,
          )
        ],
      ),
    );

Widget fileTypeWidget(String type, String size, String iconPath, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          Container(
            height: 20.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: color == orange ? orange.withOpacity(0.8) : color,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type,
                      style: TextStyle(
                        color: color == yellow ? Colors.black : Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      )),
                  Text(size,
                      style: TextStyle(
                        color: color == orange
                            ? Colors.black.withOpacity(0.5)
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
          Positioned(
            right: -30,
            bottom: -50,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(iconPath,
                  height: 20.h, width: 30.w, fit: BoxFit.contain),
            ),
          )
        ],
      ),
    ),
  );
}

Widget subtitle(FileSystemEntity entity) {
  return FutureBuilder<FileStat>(
    //dosya pathı
    future: entity.stat(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (entity is File) {
          int size = snapshot.data!.size;

          return Text(
            FileManager.formatBytes(size),
          );
        }

        /* return Text(
          "${snapshot.data!.modified}".substring(0, 10),
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        );*/
      } else {}
      return const Text("");
    },
  );
}

//Klasör boyut widgetı
Widget folderSize(FileSystemEntity entity) {
  return FutureBuilder<FileStat>(
    future: entity.stat(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (entity is File) {
          int size = snapshot.data!.size;

          return Text(
            FileManager.formatBytes(size),
          );
        } else if (entity is Directory) {
          String dosyaKonum = "$entity";
          String exDosyaKonum = extractTextBetweenSingleQuotes(dosyaKonum);
          int totalSize = 0;
          Directory folder = Directory('$exDosyaKonum');
          List<FileSystemEntity> files = folder.listSync(recursive: true);
          for (FileSystemEntity file in files) {
            if (file is File) {
              totalSize += file.lengthSync();
            }
          }
          return Text(
            FileManager.formatBytes(totalSize),
          );
        }
      } else if (entity is Directory) {
        return Text('data');
      }

      return const Text("");
    },
  );
}

int calculateTotalSize(FileSystemEntity entity) {
  if (entity is File) {
    return entity.lengthSync();
  } else if (entity is Directory) {
    String dosyaKonum = "$entity";
    String exDosyaKonum = extractTextBetweenSingleQuotes(dosyaKonum);
    int totalSize = 0;
    Directory folder = Directory('$exDosyaKonum');
    List<FileSystemEntity> files = folder.listSync(recursive: true);
    for (FileSystemEntity file in files) {
      if (file is File) {
        totalSize += file.lengthSync();
      }
    }
    return totalSize;
  } else {
    return 0;
  }
}

/*int compare(FileSystemEntity a, FileSystemEntity b) {
       int sizeA =  calculateTotalSize(a);
       int sizeB =  calculateTotalSize(b);
                                  
       return sizeA.compareTo(sizeB);
      }*/

Widget getLength(FileSystemEntity entity) {
  return FutureBuilder<FileStat>(
    future: entity.stat(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (entity is Directory) {
          String dosyaKonum = "$entity";
          String exDosyaKonum = extractTextBetweenSingleQuotes(dosyaKonum);
          int sayac = 0;
          int sayac2 = 0;
          Directory folder = Directory('$exDosyaKonum');
          List<FileSystemEntity> files = folder.listSync(recursive: true);
          for (FileSystemEntity file in files) {
            if (file is File) {
              sayac++;
            } else if (file is Directory) {
              sayac2++;
            }
          }
          return Text("Dosya: $sayac / Klasör:$sayac2");
        }
      } else if (entity is Directory) {
        return Text('data');
      }

      return const Text("Dosya");
    },
  );
}

// dosya uzantısı veren widget
Widget fileEx(FileSystemEntity entity) {
  return FutureBuilder<FileStat>(
    //dosya pathı
    future: entity.stat(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (entity is File) {
          //int size = snapshot.data!.size;

          return Text(
            FileManager.getFileExtension(entity),
          );
        }
      }

      return const Text("Klasör");
    },
  );
}

/*int calculateFolderSize(Directory folder) {
  int totalSize = 0;

  List<FileSystemEntity> files = folder.listSync(recursive: true);

  for (FileSystemEntity file in files) {
    if (file is File) {
      totalSize += file.lengthSync();
    }
  }

  return totalSize;
}*/

// tırnak içersindeki dosya pathini alabilmemiz için fonk.
String extractTextBetweenSingleQuotes(String input) {
  RegExp regex = RegExp("'(.*?)'");
  Match? match = regex.firstMatch(input);

  if (match != null && match.groupCount >= 1) {
    return match.group(1)!;
  }
  return '';
}

//Oluşturulma tarihi Widget
Widget subtitle4(FileSystemEntity entity) {
  return FutureBuilder<FileStat>(
    //dosya pathı
    future: entity.stat(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (entity is File) {
          //int size = snapshot.data!.size;

          return Text(
            "${snapshot.data!.modified}".substring(0, 10),
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          );
        } else if (entity is Directory) {
          return Text(
            "${snapshot.data!.modified}".substring(0, 10),
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          );
        }
      }

      return const Text("accc");
    },
  );
}

/*Widget getAllFileSize(FileSystemEntity entity) {
  String folderPath =
      entity; // Klasör yolunu belirtin

  int totalSize = 0;

  Directory folder = Directory(entity);
  if (folder.existsSync()) {
    List<FileSystemEntity> files = folder.listSync(recursive: true);

    for (FileSystemEntity file in files) {
      if (file is File) {
        totalSize += file.lengthSync();
      }
    }
  }

  return Text(': $totalSize byte');
}*/
