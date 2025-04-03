import 'package:flutter/material.dart';
import 'package:tracks/back/enigme.dart';
import 'package:tracks/back/enigmeImage.dart';
import 'package:tracks/pagesWeb/16_editerCreerEnigmeText.dart';
import 'package:tracks/pagesWeb/4_accueil.dart';
import 'package:tracks/pagesWeb/7_editerCreerPointPassage.dart';
import 'package:tracks/pagesWeb/6_editerCreerCircuit.dart';
import 'package:tracks/back/pointpassage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracks/back/circuit.dart';
import 'package:tracks/pagesWeb/12_profile.dart';
import 'package:tracks/back/enigmeText.dart';


class EnigmesExistantes extends StatefulWidget {
  final String userID;
  final String circuitID;
  final String pointPassageID;
  EnigmesExistantes({super.key, required this.userID, required this.circuitID, required this.pointPassageID});

  @override
  State<StatefulWidget> createState() => _EnigmesExistantes(userID, circuitID, pointPassageID);
}

class _EnigmesExistantes extends State<EnigmesExistantes> {
  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);
  static const Color grisClair = Color(0xFFd9d9d9);

  final String _userID;
  final String _circuitID;
  final String _pointPassageID;
  String _mailUser = "";

  List<String>? _userLstCircuit =[];
  List<String>? _userLstEnigme = [];
  late PointPassage _pointPassage;
  List<String>_lstEnigmeTextID =[];
  List<String>_lstEnigmeImageID =[];
  List<EnigmeText> _lstEnigmeText = [];
  List<EnigmeImage> _lstEnigmeImage = [];
  List<Widget> _listWidgetEnigme = [];
  List<Circuit> _lstCircuit = [];
  int indexPointPassage = 0;


  _EnigmesExistantes(this._userID, this._circuitID, this._pointPassageID);

  ///Initialisation des variables
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  ///récupère les données de l'utilisateur dans la base de donnée
  Future<void> getUserData() async {
    print("getUserData");
    final docRef = FirebaseFirestore.instance.collection("users").doc(_userID);
    final get = docRef.get();
    final user = await get.then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data;
      },
      onError: (e) => print("Error getting document: $e"),
    );
    setState(() {
      _mailUser = user["email"];
      _userLstEnigme = user['lstEnigme'] is Iterable
          ? List.from(user['lstEnigme'])
          : null;
      _userLstCircuit = user['lstEnigme'] is Iterable
          ? List.from(user['lstEnigme'])
          : null;
    });
    getEnigme();
    getCircuit();
  }

  Future<void> getCircuit() async{
    for (int i=0; i<_userLstCircuit!.length; i++){
      final ref = FirebaseFirestore.instance.collection("circuit").doc(_userLstCircuit![i]).withConverter(
        fromFirestore: Circuit.fromFirestore,
        toFirestore: (Circuit circuit, _) => circuit.toFirestore(),
      );
      final docSnap = await ref.get();
      setState(() {
        _lstCircuit.add(docSnap.data()!) ;
      });
    }
  }


  Future<void> getEnigme() async {
    print("getEnigme");
    for (int i = 0; i < _userLstEnigme!.length; i++) {
      final enigmeGlobal = await FirebaseFirestore.instance.collection("Enigme")
          .doc(_userLstEnigme![i]).get()
          .then(
            (DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data;
        },
        onError: (e) => print("Error getting document: $e"),
      );
      print(enigmeGlobal["type"]);
      if (enigmeGlobal["type"] == "EnigmeImage") {
        print("editerCreerPointPassage getEnigmeImage");
        final enigme = await FirebaseFirestore.instance
            .collection("EnigmeImage")
            .doc(_userLstEnigme![i])
            .withConverter(
          fromFirestore: EnigmeImage.fromFirestore,
          toFirestore: (EnigmeImage enigme, _) =>
              enigme.toFirestore(),
        ).get();
        setState(() {
          _lstEnigmeImage.add(enigme.data()!);
          _lstEnigmeImageID.add(_lstEnigmeImage[_lstEnigmeImage.length-1].getEnigmeID()!);
        });
      } else if (enigmeGlobal["type"] == "EnigmeText") {
        print("editerCreerPointPassage getEnigmeText");
        final enigme = await FirebaseFirestore.instance
            .collection("EnigmeText")
            .doc(_userLstEnigme![i])
            .withConverter(
          fromFirestore: EnigmeText.fromFirestore,
          toFirestore: (EnigmeText enigme, _) =>
              enigme.toFirestore(),
        ).get();
        setState(() {
          _lstEnigmeText.add(enigme.data()!);
          _lstEnigmeTextID.add(_lstEnigmeText[_lstEnigmeText.length-1].getEnigmeID()!);
        });
      }
    }
    buildWidget();
    getPointPassage();
  }

  Future<void> getPointPassage() async {
      final ref = FirebaseFirestore.instance.collection("pointPassage").doc(
          _pointPassageID).withConverter(
        fromFirestore: PointPassage.fromFirestore,
        toFirestore: (PointPassage pointPassage, _) =>
            pointPassage.toFirestore(),
      );
      final docSnap = await ref.get();
      setState(() {
        _pointPassage=docSnap.data()!;
      });
    }

  ///Rempli [_listWidgetEnigme] et [_listWidgetPointPassage]
  Future<void> buildWidget() async {
    //creation des widget d'enigme
    for (int i = 0; i < _lstEnigmeText.length; i++) {
      Widget widgEnigme = buildEnigmeCard(
          context, _lstEnigmeText[i].getEnigmeID()!,
          _lstEnigmeText[i].getNomEnigme()!);
      setState(() {
        _listWidgetEnigme.add(widgEnigme);
      });
    }
    for (int i = 0; i < _lstEnigmeImage.length; i++) {
      Widget widgEnigme = buildEnigmeCard(
          context, _lstEnigmeImage[i].getEnigmeID()!,
          _lstEnigmeImage[i].getNomEnigme()!);
      setState(() {
        _listWidgetEnigme.add(widgEnigme);
      });
    }
    print("_listWidgetEnigme : "+_listWidgetEnigme.length.toString());
  }

  void choisir(String enigmeID) {
    _pointPassage.setEnigme(enigmeID);
    _pointPassage.mettreAJourBD();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PointDePassagePage(userID: _userID,
                circuitID: _circuitID,
                pointPassageID: _pointPassageID,)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClair,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 120,
        backgroundColor: vertMoyen,
        automaticallyImplyLeading: false,
        //pas de flèche retour en arrière
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 15),
            const Text("Enigmes existantes",
                style: TextStyle(fontSize: 16, color: Colors.white)),
            Expanded(
              child: Center(
                child:
                Image.asset('assets/images/logoSansFond.png', height: 80),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => profile(userID: _userID),
                      ),
                    );
                  },
                  icon: Icon(Icons.account_circle_sharp,
                      color: Colors.white, size: 25),
                  label: Text(_mailUser,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white)), // Texte à côté de l'icône
                )
              ],
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //circuits
                    buildSectionTitle(
                        context, "Enigmes"), // Passer context ici
                  ],
                ),
              ),
              const SizedBox(height: 10),
              footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget footer() {
    return Container(
      color: vertMoyen,
      height: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 15),
          Text(
            "@Copyright",
            style: TextStyle(
              fontSize: 15,
              color: vertFonce,
            ),
          ),
        ],
      ),
    );
  }

  //création de conteneurs
  Widget buildSectionTitle(BuildContext context, String title) {
    // Accepter context ici
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //titre
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  title,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: vertMoyen),
                ),
              ),

              //+
              IconButton(
                icon: const Icon(Icons.add),
                color: vertMoyen,
                iconSize: 30.0,
                padding: const EdgeInsets.all(10.0),
                onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditionCreationEnigmeText(userID: _userID, circuitID: _circuitID, pointPassageID: _pointPassageID, provenance: "BanqueEnigme",),
                      ),
                    );

                },
              ),
            ],
          ),
          ..._listWidgetEnigme.toList()
        ],
      ),
    );
  }

  Widget buildEnigmeCard(BuildContext context, String enigmeID,
      String enigme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.0, left: 10, right: 10),
      // Padding de 20px pour la dernière carte
      child: Card(
        color: vertMoyen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            // Utilisation de Row pour diviser en trois colonnes
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enigme,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),


              // Troisième colonne : Boutons (Éditer/Supprimer)
              Column(
                children: [
                  Row(
                    children: [
                      //bouton choisir
                      ElevatedButton(
                        onPressed: () => choisir(enigmeID),
                        // Action pour choisir
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20.0),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(1, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_outlined,
                              color: Colors.white,
                              size: 35,
                            ),

                            const Text(
                              "Choisir",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 2),

                      //bouton editer
                      ElevatedButton(
                         onPressed: () {
                           Navigator.pushReplacement(
                             context,
                             MaterialPageRoute(
                                 builder: (context) => EditionCreationEnigmeText(
                                     userID: _userID, circuitID: _circuitID, pointPassageID: _pointPassageID, enigmeID: enigmeID ,provenance: "BanqueEnigme",)),
                           );
                         }, // Action pour éditer
                         style: ElevatedButton.styleFrom(
                           padding: const EdgeInsets.all(20.0),
                           backgroundColor: Colors.transparent,
                           foregroundColor: Colors.transparent,
                           shadowColor: Colors.transparent,
                           minimumSize: const Size(1, 1),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(200.0),
                           ),
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Icon(
                              Icons.edit,
                               color: Colors.white,
                               size: 35,
                             ),

                             const Text(
                               "Editer",
                               style: TextStyle(
                                 fontSize: 13,
                                 color: Colors.white,
                               ),
                             ),
                           ],
                         ),
                       ),
                       const SizedBox(width: 2),

                       //bouton supprimer
                       ElevatedButton(
                         onPressed: (){
                           showDialog(
                             context: context,
                             builder: (context) => AlertDialog(
                               backgroundColor: grisClair,  // Fond gris clair pour l'alerte
                               title: const Text("Suppression de l'énigme"),  // Titre de l'alerte
                               content: Text(
                                 "Êtes-vous sûr de vouloir supprimer cette énigme ?", // Message de confirmation
                               ),
                               actions: [
                                 // Bouton "Non" pour annuler
                                 TextButton(
                                   onPressed: () {
                                     Navigator.of(context).pop();
                                     // Ferme la boîte de dialogue sans rien faire
                                   },
                                   style: TextButton.styleFrom(
                                     backgroundColor: Colors.white,  // Fond blanc
                                     foregroundColor: Colors.black,   // Texte noir
                                   ),
                                   child: const Text("Non"),  // Texte du bouton
                                 ),
                                 // Bouton "Oui" pour confirmer la suppression
                                 TextButton(
                                   onPressed: () => supprimerEnigme(
                                       enigmeID), // Action pour supprimer
                                   style: TextButton.styleFrom(
                                     backgroundColor: Colors.white,  // Fond blanc
                                     foregroundColor: Colors.black,   // Texte noir
                                   ),
                                   child: const Text("Oui"),  // Texte du bouton
                                 ),
                               ],
                             ),
                           );
                         },
                         style: ElevatedButton.styleFrom(
                           padding: const EdgeInsets.all(20.0),
                           backgroundColor: Colors.transparent,
                           foregroundColor: Colors.transparent,
                           shadowColor: Colors.transparent,
                           minimumSize: const Size(10, 10),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(200.0),
                           ),
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Icon(
                               Icons.delete,
                               color: Colors.white,
                               size: 35,
                             ),

                             const Text(
                               "Supprimer",
                               style: TextStyle(
                                 fontSize: 13,
                                 color: Colors.white,
                               ),
                             ),
                           ],
                         ),
                       ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> supprimerEnigme(String enigmeID) async {
    print("remove : "+ enigmeID);
    //suppression de tous les usages
    for (int i=0; i<_lstCircuit.length; i++){
      List<dynamic>? _lstPointPassage = _lstCircuit[i].getLstPointPassage();
      for (int j=0; j<_lstPointPassage!.length; i++){
        final pointPassageEnigme = await FirebaseFirestore.instance.collection("PointPassage")
            .doc(_lstPointPassage[j]).get()
            .then(
                (DocumentSnapshot doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data;
            },
            onError: (e) => print("Error getting document: $e"),
        );
        if (pointPassageEnigme==enigmeID){
          final docRef = await FirebaseFirestore.instance.collection("PointPassage").doc(_lstPointPassage[j]);
          final updates = <String, dynamic>{
            "Enigmes": "",
          };
          docRef.update(updates);
        }
      }
    }
    print("after boucles x2");
    //suppression dans la liste de l'utilisateur
    _userLstEnigme!.remove(enigmeID);
    final docRef = await FirebaseFirestore.instance.collection("users").doc(_userID);
    final updates = <String, dynamic>{
      "lstEnigme": _userLstEnigme,
    };
    docRef.update(updates);
    //suppression dans l'affichage
    int index = _lstEnigmeTextID.indexOf(enigmeID);
    if (index>=0){
      await _lstEnigmeText[index].supprimerEnigme();
    }
    index = _lstEnigmeImageID.indexOf(enigmeID);
    if (index>=0){
      await _lstEnigmeImage[index].supprimerEnigme();
    }

    print("before replacement");
    //recharger la page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EnigmesExistantes(userID: _userID, circuitID: _circuitID, pointPassageID: _pointPassageID,),
      ),
    );
  }
}
