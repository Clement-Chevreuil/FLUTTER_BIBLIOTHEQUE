import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Interfaces/media_compare.dart';
import 'package:flutter_project_n1/Interfaces/media_dashboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:getwidget/getwidget.dart';
import 'media_manager.dart';
import 'dart:typed_data';
import 'dart:io';

import '../Database/database_media.dart';
import '../Database/database_genre.dart';
import '../Database/database_reader.dart';
import '../Database/database_init.dart';
import '../Model/media.dart';
import '../Logic/helper.dart';

import 'genres_index.dart';
import 'package:flutter/material.dart';
import 'media_dashboard.dart'; // Importez le fichier page1.dart
import 'media_compare.dart';
import 'media_index.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool activeMediaIndex = true;
  int _currentIndex = 0;
  late DatabaseInit _databaseInit;

  
  final home = new MediaIndex("Series");

  final List<String> sidebarItems = [
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies"
  ];

    final List<String> ItemsTitle = [
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies",
    "Dashboard",
    "Compare",
  ];
  List<IconData> itemIcons = [
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie
  ];
  String selectedTableName = "Series";

  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();
  
  }



  
  static int _currentPage = 0;
  PageController _pageController = PageController();
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
      _pageController.jumpToPage(_currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ItemsTitle[_currentPage]),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
  decoration: BoxDecoration(
    color: Colors.blue,
  ),
  child: Center(
    child: Text(
      'Menu',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
      ),
    ),
  ),
),
                  for (int i = 0; i < sidebarItems.length; i++)
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        backgroundColor: sidebarItems[i] == selectedTableName
                            ? MaterialStateProperty.all(Colors.transparent)
                            : MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        setState(() {
                    
                           selectedTableName = sidebarItems[i];
                          _changePage(i);

                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            itemIcons[i], // Utilisez l'icône correspondante
                            color: itemIcons[i] == selectedTableName
                                ? Colors.blue
                                : Colors.black, // Couleur de l'icône
                          ),
                          SizedBox(
                              width: 8), // Espacement entre l'icône et le texte
                          Text(
                            sidebarItems[i],
                            style: TextStyle(
                              fontWeight: sidebarItems[i] == selectedTableName
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      activeMediaIndex = false;
                      setState(() {
                        _changePage(6);
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Dashboard"),
                  ),
                  TextButton(
                    onPressed: () {
                      activeMediaIndex = false;
                      setState(() {
                        _changePage(7);
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Compare Media With Other"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _databaseInit.exportDatabaseWithUserChoice();
                    },
                    child: Text("Exporter BDD"),
                  ),
                  TextButton(
                    onPressed: () {
                      replaceDatabase();
                      Navigator.pop(context);
                    },
                    child: Text("Remplacer BDD"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: 
          PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), 
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: <Widget>[
                 MediaIndex("Series",),
                  MediaIndex("Animes"),
                  MediaIndex("Games"),
                  MediaIndex("Webtoons"),
                  MediaIndex("Books"),
                  MediaIndex("Movies"),
                  MediaDashboard( onPageChanged: (page) {
    _changePage(page); // Appel de la fonction _changePage pour mettre à jour la page
  },),
                  MediaCompare(),
              ],
            ),
    );
  }



   Future replaceDatabase() async {
    try {
      // Sélectionner un fichier depuis l'appareil      
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.any);


      if (result != null) {
        // Récupérer le fichier sélectionné
        final file = File(result.files.single.path!);

        String sourceDBPath = p.join(await getDatabasesPath(), "maBDD2.db");
        File sourceFile = File(sourceDBPath);

        // Supprimer l'ancien fichier de base de données s'il existe
        if (await sourceFile.exists()) {
          await sourceFile.delete();
        }

        _databaseInit.closeDatabase();
        final appDirectory = await getDatabasesPath();
        final databasePath =
            '${appDirectory}/maBDD3.db'; // Changement de nom ici
        await file.copy(databasePath);
        _databaseInit.initDatabase("maBDD3.db");
        //loadMedia();

        return sourceFile.path;
      } else {
        // L'utilisateur a annulé la sélection du fichier
        return null;
      }
    } catch (e) {
      print(e);
      // Gérer l'erreur de remplacement du fichier de base de données
      return null;
    }
  }
}