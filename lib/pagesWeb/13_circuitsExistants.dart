import 'package:flutter/material.dart';
import 'package:tracks/pagesWeb/5_editerCreerPartie.dart';
import 'package:tracks/pagesWeb/6_editerCreerCircuit.dart';
import 'package:tracks/back/pointpassage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracks/back/circuit.dart';
import 'package:tracks/pagesWeb/12_profile.dart';
import 'package:tracks/back/partie.dart';


class CircuitsExistants extends StatefulWidget {
  final String userID;
  final String partieID;
  CircuitsExistants({super.key, required this.userID, required this.partieID});

  @override
  State<StatefulWidget> createState() => _CircuitsExistants(userID, partieID);
}

class _CircuitsExistants extends State<CircuitsExistants> {
  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);
  static const Color grisClair = Color(0xFFd9d9d9);

  final String _userID;
  final String _partieID;
  String _mailUser = "";
  List<dynamic>? _userLstCircuit = [];
  List<String>? _userLstPartie = [];
  List<Partie?> _lstPartie = [];
  List<Widget> _listWidgetPartie = [];
  List<Circuit?> _lstCircuit = [];
  List<Widget> _listWidgetCircuit = [];
  int indexPartie = 0;


  _CircuitsExistants(this._userID, this._partieID);

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
      _userLstCircuit=user['lstCircuit'] is Iterable
          ? List.from(user['lstCircuit'])
          : null;
      _userLstPartie = user['lstPartie'] is Iterable
          ? List.from(user['lstPartie'])
          : null;
    });
    getCircuit();
  }

  ///récupère les données des circuit de l'utilisateur dans la base de donnée et crée des instances de circuit correspondant
  ///
  /// modifier pour ne pas créer une instance à chaque fois (pour des raisons de temps)
  Future<void> getCircuit() async{
    print("getCircuit");
    for (int i=0; i<_userLstCircuit!.length; i++){
      final ref = FirebaseFirestore.instance.collection("circuit").doc(_userLstCircuit![i]).withConverter(
        fromFirestore: Circuit.fromFirestore,
        toFirestore: (Circuit circuit, _) => circuit.toFirestore(),
      );
      final docSnap = await ref.get();
      setState(() {
        _lstCircuit.add(docSnap.data()) ;
      });
    }
    getPartie();
  }

  Future<void> getPartie() async{
    print("getPartie");
    for (int i=0; i<_userLstPartie!.length; i++){
      final ref = FirebaseFirestore.instance.collection("partie").doc(_userLstPartie![i]).withConverter(
        fromFirestore: Partie.fromFirestore,
        toFirestore: (Partie partie, _) => partie.toFirestore(),
      );
      final docSnap = await ref.get();
      setState(() {
        _lstPartie.add(docSnap.data()) ;
      });
    }
    for(int i= 0; i<_lstPartie.length; i++){
      if(_lstCircuit[i]!.getID() == _partieID){
        indexPartie = i;
      }
    }
    buildWidget();
  }

  ///Rempli [_listWidgetCircuit] et [_listWidgetPartie]
  Future<void> buildWidget() async {
    //creation des widget de circuit
    for (int i=0; i<_lstCircuit.length; i++) {
      String nomCircuit = await _lstCircuit[i]!.getNom().toString();
      List<String> lstNomPP = [];
      List<dynamic>? lstPP = _lstCircuit[i]!.getLstPointPassage();


      for (int j=0; j<lstPP!.length; j++){
        PointPassage? pp = await _lstCircuit[i]!.recupererPointPassageBD(lstPP[j]!.toString());
        lstNomPP.add(pp!.getNom()!);
      }
      Widget widgCircuit = buildCircuitCard(context, _lstCircuit[i]!.getID()!,
          nomCircuit, lstNomPP);
      setState(() {
        _listWidgetCircuit.add(widgCircuit);
      });
    }
  }

  ///Supprime le circuit dont l'ID est passé en paramètre de la base de donnée
  void supprimerCircuit(String circuitID){
    int index= _userLstCircuit!.indexOf(circuitID);
    print("remove Circuit : "+circuitID);
    _lstCircuit[index]!.supprimerCircuit();
    setState(() {
      _userLstCircuit!.remove(circuitID);
    });
    final data = <String, dynamic>{
      'lstCircuit': _userLstCircuit,
    };
    FirebaseFirestore.instance.collection("users").doc(_userID).update(data);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CircuitsExistants(userID: _userID, partieID: _partieID),
      ),
    );
  }

  void choisir(String circuitID){
    final data = <String, dynamic>{
      'circuit': circuitID,
    };
    FirebaseFirestore.instance.collection("partie").doc(_partieID).update(data);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditionCreationPartie(userID: _userID, partieID: _partieID, circuitID: circuitID)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("buildCircuitsExistants");
    return Scaffold(
      backgroundColor: grisClair,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 120,
        backgroundColor: vertMoyen,
        automaticallyImplyLeading: false, //pas de flèche retour en arrière
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 15),
            const Text("Circuits existants",
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
                        context, "Circuits"), // Passer context ici
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
                  // Vérification de la valeur de 'title' pour déterminer la navigation
                  if (title == "Parties") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditionCreationPartie(
                            userID: _userID
                        ),
                      ),
                    );
                    //circuits
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CircuitCreationCircuit(userID: _userID),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          if (title == "Parties") ...
          _listWidgetPartie.toList()
          else if (title == "Circuits")
            ..._listWidgetCircuit.toList()
        ],
      ),
    );
  }

  Widget buildCircuitCard(BuildContext context, String circuitID,
      String circuit, List<String> pointsDePassage) {
    List<Widget> lstPointPassage = [];
    lstPointPassage.add(Text(
      "Points de passage",
      style: const TextStyle(color: vertFonce, fontWeight: FontWeight.bold),
    ));
    if (pointsDePassage.length > 2) {
      for (int i = 0; i < 2; i++) {
        Widget pointPassage = pointPassageCard(pointsDePassage[i]);
        lstPointPassage.add(pointPassage);
      }
      lstPointPassage.add(Text(
        "...",
        style: const TextStyle(color: vertFonce, fontWeight: FontWeight.bold),
      ));
    } else {
      for (int i = 0; i < pointsDePassage.length; i++) {
        Widget pointPassage = pointPassageCard(pointsDePassage[i]);
        lstPointPassage.add(pointPassage);
      }
    }
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
              // Première colonne : Informations sur le circuit
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circuit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "${pointsDePassage.length} points de passage",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Deuxième colonne : Points de passage
              pointPassageCircuit(lstPointPassage),

              // Troisième colonne : Boutons (Choisir/Éditer/Supprimer)
              Column(
                children: [
                  Row(
                    children: [
                      //bouton choisir
                      ElevatedButton(
                        onPressed: () => choisir(circuitID), // Action pour choisir
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

                      // //bouton editer
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.pushReplacement(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => CircuitCreationCircuit(
                      //               userID: _userID, circuitID: circuitID)),
                      //     );
                      //   }, // Action pour éditer
                      //   style: ElevatedButton.styleFrom(
                      //     padding: const EdgeInsets.all(20.0),
                      //     backgroundColor: Colors.transparent,
                      //     foregroundColor: Colors.transparent,
                      //     shadowColor: Colors.transparent,
                      //     minimumSize: const Size(1, 1),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(200.0),
                      //     ),
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Icon(
                      //         Icons.edit,
                      //         color: Colors.white,
                      //         size: 35,
                      //       ),
                      //
                      //       const Text(
                      //         "Editer",
                      //         style: TextStyle(
                      //           fontSize: 13,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(width: 2),
                      //
                      // //bouton supprimer
                      // ElevatedButton(
                      //   onPressed: () => supprimerCircuit(
                      //       circuitID), // Action pour supprimer
                      //   style: ElevatedButton.styleFrom(
                      //     padding: const EdgeInsets.all(20.0),
                      //     backgroundColor: Colors.transparent,
                      //     foregroundColor: Colors.transparent,
                      //     shadowColor: Colors.transparent,
                      //     minimumSize: const Size(10, 10),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(200.0),
                      //     ),
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Icon(
                      //         Icons.close,
                      //         color: Colors.white,
                      //         size: 35,
                      //       ),
                      //
                      //       const Text(
                      //         "Supprimer",
                      //         style: TextStyle(
                      //           fontSize: 13,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
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

  Widget pointPassageCircuit(List<Widget> lstPointPassage){
    if(lstPointPassage.length == 1) return Container();
    return Container(
      width: 300,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lstPointPassage.toList(),
      ),
    );
  }

  Widget pointPassageCard(String nom) {
    return Text(
      nom,
      style: TextStyle(
        fontSize: 13,
        color: vertClair,
      ),
    );
  }
}
