import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracks/back/circuit.dart';
import 'package:tracks/back/pointpassage.dart';
import 'package:tracks/back/partie.dart';
import 'package:tracks/pagesWeb/6_editerCreerCircuit.dart';
import 'package:tracks/pagesWeb/13_circuitsExistants.dart';

import 'package:tracks/qrcode/qrcode.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '4_accueil.dart';
import '6_editerCreerCircuit.dart';
import 'package:tracks/pagesWeb/tracksFooter.dart';

class EditionCreationPartie extends StatefulWidget {
  final String userID;
  final String partieID;
  final String circuitID;

  const EditionCreationPartie(
      {super.key, required this.userID, this.partieID ="" , this.circuitID=""});

  @override
  _EditionCreationPartieState createState() =>
      _EditionCreationPartieState(userID,partieID,circuitID);
}

class _EditionCreationPartieState extends State<EditionCreationPartie> {
  final String _userID;
  String _mailUser = "";
  List<dynamic>? _userLstPartie = [];
  List<dynamic>? _userLstCircuit = [];
  List<Circuit?> _lstCircuit = [];
  late Widget _widgetCircuit = Container();

  //Variables de Partie
  String _partieID;
  Partie? _partie;
  String? _circuitID = ""; // Circuit ID fixe PackgBsyBbLUW3eDSgOW
  Circuit? _circuit;


  bool _isEditingTextTitre = false;
  late String? initialTextTitre = "Nouvelle partie";
  late TextEditingController _editingControllerTitre;


  _EditionCreationPartieState(this._userID, this._partieID, this._circuitID);


  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);
  static const Color grisClair = Color(0xFFe9e9e9);

  double cardHeight = 138;

  int visibleCircuits = 2; // Nombre de circuits visibles initialement

  ///Initialisation des variables
  @override
  void initState() {
  _widgetCircuit = Container();
    super.initState();
    getUserData();
  }

  ///fonction dispose modifiée pour les zones de texte éditables
  @override
  void dispose() {
    setState(() {
      _editingControllerTitre.dispose();
    });
    super.dispose();
  }

  ///Initialise les variables liées aux textes éditables
  void initTextEdit() {
    setState(() {
      initialTextTitre = _partie!.getNom();
      _editingControllerTitre = TextEditingController(text: initialTextTitre);
    });

  }

  ///récupère les données de l'utilisateur dans la base de donnée
  Future<void> getUserData() async {
    final docRef = FirebaseFirestore.instance.collection("users").doc(_userID);
    final test = docRef.get();
    final user = await test.then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data;
      },
      onError: (e) => print("Error getting document: $e"),
    );
    setState(() {
      _mailUser = user["email"];
      _userLstCircuit =
          user['lstCircuit'] is Iterable ? List.from(user['lstCircuit']) : null;
      _userLstPartie =
          user['lstPartie'] is Iterable ? List.from(user['lstPartie']) : null;
    });
    _userLstPartie ??= [];
    if (_partieID.isEmpty) {
      creerPartieBD();
    } else {
      getPartie();
    }
  }

  Future<void> creerPartieBD() async {
    Partie partie = await Partie.createPartie(initialTextTitre!,_circuitID!);
    _circuitID="";
    setState(() {
      _partieID = partie.getPartieID();
      _partie = partie;
      _userLstPartie!.add(_partie!.getPartieID());
    });
    final data = <String, dynamic>{
      'lstPartie': _userLstPartie,
    };
    FirebaseFirestore.instance.collection("users").doc(_userID).update(data);
    initTextEdit();
    getCircuit();
  }

  Future<void> getPartie() async {
    print("getPartie");
    final ref = FirebaseFirestore.instance.collection("partie").doc(_partieID).withConverter(
      fromFirestore: Partie.fromFirestore,
      toFirestore: (Partie partie, _) => partie.toFirestore(),
    );
    final docSnap = await ref.get();
    final partie = docSnap.data();
    setState(() {
      _partie=partie;
    });
    initTextEdit();
    getCircuit();
  }

  ///récupère les données des circuit de l'utilisateur dans la base de donnée et crée des instances de circuit correspondant
  ///
  /// modifier pour ne pas créer une instance à chaque fois (pour des raisons de temps)
  Future<void> getCircuit() async {
    if (_partie!.getCircuitID()!.length !=0){
      final ref = FirebaseFirestore.instance
          .collection("circuit")
          .doc(_partie!.getCircuitID())
          .withConverter(
        fromFirestore: Circuit.fromFirestore,
        toFirestore: (Circuit circuit, _) => circuit.toFirestore(),
      );
      final docSnap = await ref.get();
      setState(() {
        _circuit= docSnap.data();
      });
    }
    buildWidget();
  }

  Future<void> buildWidget() async {
    print("buildWidget CreerPartie");
    List<String> lstNomPP = [];
    List<dynamic> lstPP = [];
    if (_circuit != null) {
      lstPP = _circuit!.getLstPointPassage()!;
      if (lstPP.length > 2) {
        for (int i = 0; i < 2; i++) {
          PointPassage? pp =
          await _circuit!.recupererPointPassageBD(lstPP[i]!.toString());
          lstNomPP.add(pp!.getNom()!);
        }
        setState(() {
          _widgetCircuit = buildCircuitCard(context, _circuit!, lstNomPP);
        });
      } else if (lstPP.length != 0) {
        for (int i = 0; i < lstPP.length; i++) {
          PointPassage? pp =
          await _circuit!.recupererPointPassageBD(lstPP[i]!.toString());
          lstNomPP.add(pp!.getNom()!);
        }
        setState(() {
          _widgetCircuit = buildCircuitCard(context, _circuit!, lstNomPP);
        });
      }else{
        setState(() {
          _widgetCircuit = buildCircuitCard(context, _circuit!, lstNomPP);
        });
      }
    }else {
      _widgetCircuit = Container();
    }
  }

  Future<bool> enregistrePartie() async{
    print("enregistrerPartie");
    if (_partie!.getNom().length == 0) {
      print("Vous devez donner un titre à votre partie");
      return false;
    } else {
      await _partie!.mettreAJourBD();
      print("enregistrerPartie");
      return true;
    }
  }

  Future<void> setChoixCircuit() async{
    if(await enregistrePartie()){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CircuitsExistants(
                  userID: _userID, partieID: _partie!.getPartieID(),)),
      );
    }
  }

  Future<void> setAccueil() async{
    if(await enregistrePartie()){
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
          builder: (context) => AccueilWeb(userID: _userID),
    )
      );
    }
  }



  ///Supprime le circuit dont l'ID est passé en paramètre de la base de donnée
  void supprimerCircuit(String circuitID) {
    print("supprimer");
    int index = _userLstCircuit!.indexOf(circuitID);
    print("Id circuit remove: " + circuitID);
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
        builder: (context) => EditionCreationPartie(
            userID: _userID, circuitID: _circuitID!, partieID: _partieID),
      ),
    );
  }

  void supprimerPartie() {
    _partie!.supprimerPartie();
    setState(() {
      _userLstPartie!.remove(_partieID);
    });
    final data = <String, dynamic>{
      'lstPartie': _userLstPartie,
    };
    FirebaseFirestore.instance.collection("users").doc(_userID).update(data);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AccueilWeb(userID: _userID),
      ),
    );
  }

  /// Affiche une boîte de dialogue contenant les options pour afficher,
  /// télécharger ou imprimer les QR Codes associés à une partie
  /// et les points de passage de son circuit associé.
  void showQRCodeDialog() async {
    // Liste des points de passage avec leurs noms et IDs
    List<Map<String, String>> points = [];

    // Récupération des informations sur le circuit et ses points de passage
    if (_circuit != null) {

      // Récupère la liste des IDs des points de passage associés au circuit
      final lstPointPassageIDs = _circuit!.getLstPointPassage() ?? [];

      // Boucle pour récupérer les noms et IDs des points de passage depuis la base de données
      for (var id in lstPointPassageIDs) {
        PointPassage? point = await _circuit!.recupererPointPassageBD(id.toString());
        if (point != null) {
          // Ajoute le point de passage avec son nom et son ID à la liste
          points.add({
            'name': point.getNom() ?? "Nom indisponible",
            'id': id.toString(),
          });
        }
      }
    }

    // Affichage de la boîte de dialogue avec les options pour les QR Codes
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("QR Codes"), // Titre de la boîte de dialogue
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Option pour afficher le QR Code de la partie
                ListTile(
                  title: const Text(
                    "QR Code de la partie",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.qr_code), // Icône QR Code
                  onTap: () {
                    // Ferme la boîte de dialogue et ouvre l'écran du QR Code de la partie
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRCode(text: 'p$_partieID'), // QR Code de la partie
                      ),
                    );
                  },
                ),
                const Divider(), // Séparateur visuel


                // Section pour les points de passage
                const Text(
                  "QR Codes des points de passage",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Liste des points de passage avec leurs QR Codes
                ...points.asMap().entries.map((entry) {
                  final point = entry.value; // Récupère un point de passage
                  return ListTile(
                    title: Text("Point de passage : ${point['name']}"),
                    trailing: const Icon(Icons.qr_code), // Icône QR Code
                    onTap: () {
                      // Ferme la boîte de dialogue et ouvre l'écran du QR Code du point de passage
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRCode(
                            text: 'e${point['id']}' ?? "", // QR Code du point de passage (ID)
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            // Bouton pour télécharger tous les QR Codes au format PDF
            ElevatedButton.icon(
              onPressed: () async {
                // Génère un PDF contenant tous les QR Codes (partie et points du circuit)
                final pdfData = await generateAllQrCodesPdf(
                  PdfPageFormat.a4,
                  _partieID,
                  points,
                );
                // Propose de partager ou de télécharger le fichier PDF
                await Printing.sharePdf(
                  bytes: pdfData,
                  filename: 'All_QRCodes.pdf',
                );
              },
              icon: const Icon(Icons.download), // Icône de téléchargement
              label: const Text("Télécharger tout"),
            ),

            // Bouton pour imprimer tous les QR Codes
            ElevatedButton.icon(
              onPressed: () async {
                // Génère un PDF contenant tous les QR Codes pour l'impression
                await Printing.layoutPdf(
                  onLayout: (PdfPageFormat format) => generateAllQrCodesPdf(
                    format,
                    _partieID,
                    points,
                  ),
                );
              },
              icon: const Icon(Icons.print), // Icône d'impression
              label: const Text("Imprimer tout"),
            ),

            // Bouton pour fermer la boîte de dialogue
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Fermer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFd9d9d9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white, // couleur de la flèche retour en arrière
        ),
        toolbarHeight: 120,
        backgroundColor: const Color(0xFF4b8c72),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 15),
            Text("Edition d’une partie",
                style: TextStyle(fontSize: 16, color: Colors.white)),
            Expanded(
              child: Image.asset('assets/images/logoSansFond.png', height: 80),
            ),
            Icon(
              Icons.account_circle_sharp,
              color: Colors.white,
              size: 25,
            ),
            const SizedBox(width: 15),
            Text(_mailUser,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
            const SizedBox(width: 15),
          ],
        ),
      ),

      //contenu
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
                    //contenu
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            zoneSupprPartieBouton(),

                            buildPartieDetails(), //nb groupes, malus, photo
                            const SizedBox(height: 20),

/////////////////////////////////////////////////////CIRCUITS
                            circuit(),
                            //test(),

/////////////////////////////////////////////////////GROUPES
                          /*
                            const SizedBox(height: 20),
                            titre("Groupes"),
                            const SizedBox(height: 20),
                            buildGroupesGrid(),

                            //boutons voir plus/voir moins
                            voirPlusVoirMoins(),
                            const SizedBox(height: 20),

                            //boutons en bas de la page
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // //bouton retour/abandon
                                // ElevatedButton(
                                //   style: ElevatedButton.styleFrom(
                                //     foregroundColor: Colors.transparent,
                                //     shadowColor: Colors.transparent,
                                //     padding: const EdgeInsets.symmetric(
                                //         vertical: 20.0, horizontal: 20.0),
                                //     textStyle: const TextStyle(fontSize: 16),
                                //     backgroundColor: vertMoyen,
                                //   ),
                                //   onPressed: () {},
                                //   child: const Row(
                                //     mainAxisSize: MainAxisSize
                                //         .min, // Pour ne pas étendre le bouton
                                //     children: [
                                //       Icon(Icons.arrow_back_ios,
                                //           color: Colors.white),
                                //       SizedBox(
                                //           width:
                                //               5), // Espace entre l'icône et le texte
                                //       Text(
                                //         "Ne pas enregistrer mes modifications",
                                //         style: TextStyle(color: Colors.white),
                                //       ),
                                //     ],
                                //   ),
                                // ),

                           */
                                //bouton enregistrer
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0, horizontal: 20.0),
                                    textStyle: const TextStyle(fontSize: 16),
                                    backgroundColor: vertMoyen,
                                  ),
                                  onPressed: setAccueil,
                                  child: const Row(
                                    mainAxisSize: MainAxisSize
                                        .min, // Pour ne pas étendre le bouton
                                    children: [
                                      Icon(Icons.check, color: Colors.white),
                                      SizedBox(
                                          width:
                                              5), // Espace entre l'icône et le texte
                                      Text(
                                        "Enregistrer",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            //),
                          //],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TracksFooter(context: context),
            ],
          ),
        ),
      ),
    );
  }

  Widget circuit() {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              titre("Circuit associé à la partie"),
              IconButton(
                icon: const Icon(Icons.add),
                color: vertMoyen,
                iconSize: 30.0,
                padding: const EdgeInsets.all(10.0),
                onPressed: setChoixCircuit,
              ),
            ],
          ),
          if (_circuit != null)...[
          const SizedBox(height: 10),
          _widgetCircuit,
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => showQRCodeDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: vertMoyen,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Voir QR Codes",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
            const SizedBox(height: 10),
          ]
        ],
      ),
    );
  }

  Widget pointPassageCard(String nom) {
    return Text(
      nom,
      style: TextStyle(
        fontSize: 13,
        color: Color(0xFF5ba788),
      ),
    );
  }

  Widget zoneSupprPartieBouton() {
    return Container(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 5),


            //croix
            ElevatedButton(
              onPressed: supprimerPartie, // Action pour éditer l'image enigme
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(13.0),
                backgroundColor: Colors.transparent,
                foregroundColor: Color(0xFF5ba788),
                shadowColor: Colors.transparent,
                minimumSize: const Size(1, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Supprimer la partie",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5ba788),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.close,
                    color: vertMoyen,
                    size: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget zoneText(String titre) {
    return Container(
      width: 500,
      child: Column(
        children: [
          //titre
          Container(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    titre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4b8c72),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),

          //zone de texte éditable

          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _editTitleTextFieldTitre(),
              const SizedBox(height: 2),
              appuiEntrer(),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget appuiEntrer() {
    if (_isEditingTextTitre) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.info,
            color: vertClair,
            size: 13,
          ),
          const SizedBox(width: 5),

          Text(
            "Veuillez appuyer sur entrer pour enregistrer vos modifications",
            style: const TextStyle(
              fontSize: 13,
              color: vertClair,
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget _editTitleTextFieldTitre() {
    if (_isEditingTextTitre) {
      return Container(
        child: TextField(
          style: TextStyle(
            color: vertFonce,
            fontSize: 14,
          ),
          onSubmitted: (newValue) {
            setState(() {
              _partie!.setNom(newValue);
              initialTextTitre = newValue;
              _isEditingTextTitre = false;
            });
          },
          autofocus: true,
          controller: _editingControllerTitre,
          decoration: new InputDecoration(
            filled: true,
            fillColor: Color(0xFFe9e9e9),
            contentPadding: const EdgeInsets.all(15),
            focusedBorder: OutlineInputBorder(
              borderSide: new BorderSide(color: Color(0xFFe9e9e9)),
              borderRadius: new BorderRadius.circular(15),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: new BorderSide(color: Colors.white),
              borderRadius: new BorderRadius.circular(15),
            ),
          ),
        ),
      );
    }
    return InkWell(
        onTap: () {
          setState(() {
            _isEditingTextTitre = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xFFf2f2f2),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  initialTextTitre!,
                  style: TextStyle(
                    color: vertFonce,
                    fontSize: 14,
                  ),
                ),
                Icon(
                  Icons.edit,
                  color: vertClair,
                  size: 20,
                ),
              ],
            ),
          ),
        ));
  }

  Widget titre(String title) {
    return Container(
      child: Container(
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4b8c72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //détails de la partie
  Widget buildPartieDetails() {
    return Container(
      child: Column(
        children: [
          titre("Informations de la partie"),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    zoneText("Titre de la partie"),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                    ),
                  ],
                ),
              ),

              //image de la partie
              Container(
                padding: EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/creationPartie.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCircuitCard(BuildContext context, Circuit circuit, List<String> pointPassages) {
    if (circuit.getID()!.length==0){
      return Container();
    }
    List<Widget> lstPointPassage = [];
    for (int i=0; i<pointPassages.length; i++){
      lstPointPassage.add(Text(
        pointPassages[i],
        style: const TextStyle(color: Color(0xFF3c735d), fontSize: 13),
      ));
    }

    return Container(
      child: Card(
        color: const Color(0xFF4b8c72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            // Utilisation de Row pour diviser en trois colonnes
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Première colonne : Informations sur le circuit
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circuit.getNom()!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    circuit.getDescription()!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Deuxième colonne : Points de passage
              Container(
                width: 300,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Points de passage du circuit",
                      style: const TextStyle(
                          color: Color(0xFF3c735d),
                          fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: lstPointPassage.toList(),
                    ),
                    Text(
                      "...",
                      style: const TextStyle(
                        color: Color(0xFF3c735d),
                      ),
                    ),
                  ],
                ),
              ),

              // Troisième colonne : Boutons (Éditer/Supprimer)
              Column(
                children: [
                  Row(
                    children: [
                      //bouton editer
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CircuitCreationCircuit(
                                    userID: _userID, circuitID: circuit.getID()!)),
                          );
                        }, // Action pour éditer
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15.0),
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

                      //bouton Enlever
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: grisClair,  // Fond gris clair pour l'alerte
                              title: const Text("Suppression de la partie"),  // Titre de l'alerte
                              content: Text(
                                "Êtes-vous sûr de vouloir supprimer cette partie ?", // Message de confirmation
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
                                  onPressed: () {
                                    supprimerCircuit(circuit.getID()!); // Action pour supprimer
                                  },
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
                          padding: const EdgeInsets.all(15.0),
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
                              Icons.close,
                              color: Colors.white,
                              size: 35,
                            ),

                            const Text(
                              "Enlever",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 2),

                      //bouton echanger
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CircuitsExistants(
                                    userID: _userID, partieID: _partieID,)),
                          );
                        }, // Action pour echanger
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15.0),
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
                              Icons.cached,
                              color: Colors.white,
                              size: 35,
                            ),

                            const Text(
                              "Echanger",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 2),
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

  //Conteneur des groupes
  /*
  Widget buildGroupesGrid() {
    if (visibleGroups > 3) {
      return Container(
        height: cardHeight * groupes.length,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: visibleGroups, // Nombre de groupes visibles
          itemBuilder: (context, index) {
            // Vérifiez si l'index du groupe existe
            if (index < groupes.length) {
              return buildGroupeCard(index + 1, groupes[index]);
            } else {
              return Container(); // Renvoyer un conteneur vide si l'index dépasse
            }
          },
        ),
      );
    }
    return Container(
      height: cardHeight * 3,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: visibleGroups, // Nombre de groupes visibles
        itemBuilder: (context, index) {
          // Vérifiez si l'index du groupe existe
          if (index < groupes.length) {
            return buildGroupeCard(index + 1, groupes[index]);
          } else {
            return Container(); // Renvoyer un conteneur vide si l'index dépasse
          }
        },
      ),
    );
  }
  */
  /*
  //"cartes" des groupes contenant infos de chaques groupes
  Widget buildGroupeCard(int groupeIndex, List<String> joueurs) {
    return Container(
      height: cardHeight,
      child: Card(
        color: vertMoyen,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 400,
                      child: Text("Groupe 1",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white)),
                    ),
                    Row(
                      children: [
                        Text(
                          "Code du groupe ",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          margin: new EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            "XXX3F3",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3c735d),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              /*
              Text(
                "Groupe $groupeIndex",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),*/
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: joueurs
                    .map((joueur) => Container(
                        padding: const EdgeInsets.all(9.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text(
                          joueur,
                          style: const TextStyle(
                            color: Color(0xFF3c735d),
                          ),
                        )))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget voirPlusVoirMoins() {
    if (visibleGroups == 3) {
      return Row(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size(20, 20),
              foregroundColor: vertClair,
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            ),
            onPressed: () {
              setState(() {
                visibleGroups = (visibleGroups + 3).clamp(3, groupes.length);
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //icon time
                Icon(
                  Icons.add,
                  color: vertMoyen, // VERT MOYEN
                ),
                const SizedBox(width: 10),

                const Text(
                  "Voir plus",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(
                        0xFF4b8c72), // Couleur du texte du bouton VERT FONCE),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (visibleGroups > 3) {
      return Row(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size(20, 20),
              foregroundColor: vertClair,
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            ),
            onPressed: () {
              setState(() {
                visibleGroups = (visibleGroups - 3).clamp(2, groupes.length);
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //icon time
                Icon(
                  Icons.remove,
                  color: vertMoyen, // VERT MOYEN
                ),
                const SizedBox(width: 10),

                const Text(
                  "Voir moins",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(
                        0xFF4b8c72), // Couleur du texte du bouton VERT FONCE),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Container();
  }*/
}
