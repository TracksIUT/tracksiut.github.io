import 'package:flutter/material.dart';
import 'package:tracks/back/pointpassage.dart';
import 'package:tracks/pagesWeb/7_editerCreerPointPassage.dart';
import 'package:tracks/pagesWeb/4_accueil.dart';
import 'package:tracks/back/circuit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracks/pagesWeb/tracksFooter.dart';
import 'package:tracks/pagesWeb/15_creerOrdrePointPassage.dart';

///Création/Edition d'un circuit
///
/// [userID] l'Id de l'utilisateur connecté
/// [circuitID] l'Id du circuit que l'on veut modifier et créer si pas passé en argument
class CircuitCreationCircuit extends StatefulWidget {
  final String userID;
  final String circuitID;
  CircuitCreationCircuit(
      {super.key, required this.userID, this.circuitID = ""});

  @override
  _CircuitCreationCircuitState createState() =>
      _CircuitCreationCircuitState(userID, circuitID);
}

///Création/Edition d'un circuit
///
/// [_userID] l'Id de l'utilisateur connecté
/// [_circuitID] l'Id du circuit que l'on veut modifier/créer
class _CircuitCreationCircuitState extends State<CircuitCreationCircuit> {
  final String _userID;
  String _mailUser = "";
  String? _circuitID;

  _CircuitCreationCircuitState(this._userID, this._circuitID);

  bool aCreerBD = false;
  late Circuit? _circuit;
  List<String>? _userLstCircuit = [];
  List<String>? _userLstPartie = [];

  bool _isEditingTextNom = false;
  bool _isEditingTextDescription = false;
  late TextEditingController _editingControllerNom;
  late TextEditingController _editingControllerDescription;
  String? initialTextNom;
  late String? initialTextDescription;

  List<Widget> _lstWidgetPointPassage = [];

  int visiblePointPassage = 3;
  double cardHeight = 120;
  bool _ordrePointPassageActive = false;

  @override
  void initState() {
    super.initState();
    getUserData();
    initialTextNom = " ";
    initialTextDescription = " ";
  }

  ///fonction dispose modifiée pour les zones de texte éditables
  @override
  void dispose() {
    setState(() {
      _editingControllerNom.dispose();
      _editingControllerDescription.dispose();
    });
    super.dispose();
  }

  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);
  static const Color grisClair = Color(0xFFe9e9e9);

  ///récupère les données de l'utilisateur et lance la suite de l'initialisation
  ///
  /// lance [getCircuit] si un ID de circuit est passé en paramètre du constructeur de la classe CircuitCreationCircuit
  /// lance [creerCircuitBD] si aucun ID de circuit est passé en paramètre du constructeur de la classe CircuitCreationCircuit
  Future<void> getUserData() async {
    print("getUserData()");
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
      try {
        _userLstCircuit = user['lstCircuit'] is Iterable
            ? List.from(user['lstCircuit'])
            : null;
        _userLstPartie =
            user['lstPartie'] is Iterable ? List.from(user['lstPartie']) : null;
      } catch (e) {
        _userLstCircuit = [];
      }
    });
    if (_circuitID!.length == 0) {
      print("creerCircuitBD");
      creerCircuitBD();
    } else {
      print("getCircuit");
      getCircuit();
    }
  }

  ///Récupère le circuit à modifier depuis la Base de Données
  ///
  /// Initialise les variables de sauvegarde
  Future<void> getCircuit() async {
    print("getCircuit()");
    final ref = FirebaseFirestore.instance
        .collection("circuit")
        .doc(_circuitID)
        .withConverter(
      fromFirestore: Circuit.fromFirestore,
      toFirestore: (Circuit circuit, _) => circuit.toFirestore(),
    );

    final docSnap = await ref.get();

    if (docSnap.exists) {
      setState(() {
        _circuit = docSnap.data();

        _ordrePointPassageActive = docSnap.data()?.ordrePointPassage ?? false;
      });

      initTextEdit();
    }
  }


  ///Initialise les variables liées aux textes éditables
  void initTextEdit() {
    print("initTextEdit()");
    setState(() {
      initialTextDescription = _circuit!.getDescription()!;
      initialTextNom = _circuit!.getNom()!;

      _editingControllerNom = TextEditingController(text: initialTextNom);
      _editingControllerDescription =
          TextEditingController(text: initialTextDescription);
    });
    buildWidget();
  }

  ///Construit les passageCard qui sont affichées
  Future<void> buildWidget() async {
    print("buildWidget()");
    List<dynamic>? lstPP = _circuit!.getLstPointPassage();
    for (int i = 0; i < lstPP!.length; i++) {
      PointPassage? pointPassage =
      await _circuit!.recupererPointPassageBD(lstPP[i]);
      String IdQRCode = "";
      if (pointPassage!.getEnigme()!.length > 0) {
        IdQRCode = pointPassage.getEnigme()!;
      } else {
        IdQRCode = pointPassage.getID();
      }
      Widget widgetPointPassage = passageCard(
          pointPassage.getID(), pointPassage.getNom()!,
          pointPassage.getDescription()!, IdQRCode, 1);
      setState(() {
        _lstWidgetPointPassage.add(widgetPointPassage);
      });
    }
  }

  ///Crée un nouveau circuit
  ///
  /// Complète [_userLstCircuit] avec l'ID de ce nouveau circuit
  /// Initialise les variables de sauvegarde
  Future<void> creerCircuitBD() async {
    print("creerCircuitBD()");
    Circuit circuit =
        await Circuit.createCircuit("Nouveau circuit", "Description");
    setState(() {
      _userLstCircuit!.add(circuit.getID()!);
      _circuitID=circuit.getID();
    });
    final data = <String, dynamic>{
      'lstCircuit': _userLstCircuit,
    };
    FirebaseFirestore.instance.collection("users").doc(_userID).update(data);
    setState(() {
      _circuit = circuit;
    });
    initTextEdit();
  }

  ///enregistre dans la base de donnée les modifications faites par l'utilisateur
  void enregistrerCircuit() {
    if (_circuit!.getNom()!.length == 0) {
      print("Vous devez donner un titre à votre circuit");
    } else {
      _circuit!.mettreAJourBD();
      print("enregistrerCircuit");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AccueilWeb(userID: _userID),
        ),
      );
    }
  }

  ///Supprime le circuit en cours d'édition et renvoie à l'accueil
  ///
  /// Met à jour la base de donnée avec [_userLstCircuit].
  Future<void> supprimer() async{
    setState(() {
      _userLstCircuit!.remove(_circuitID);
      if (_userLstPartie!=null) {
        _userLstPartie!.remove(_circuitID);
      }
    });
    final data = <String, dynamic>{
      'lstCircuit': _userLstCircuit,
      'lstPartie': _userLstPartie,
    };
    await FirebaseFirestore.instance.collection("users").doc(_userID).update(data);
    _circuit!.supprimerCircuit();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AccueilWeb(userID: _userID),
      ),
    );
  }

  Future<void> supprimerPointPassage(String pointPassageID) async {
    setState(() {
      _circuit!.supprimerPointPassage(pointPassageID);
    });
    print(_circuit!.getLstPointPassage());
    final ref = FirebaseFirestore.instance
        .collection("pointPassage")
        .doc(pointPassageID)
        .withConverter(
      fromFirestore: PointPassage.fromFirestore,
      toFirestore: (PointPassage pointPassage, _) =>
          pointPassage.toFirestore(),
    );
    final docSnap = await ref.get();
    PointPassage? pointPassage = docSnap.data();
    pointPassage!.supprimerPointPassage();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CircuitCreationCircuit(userID: _userID, circuitID: _circuitID!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClair,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white, // couleur de la flèche retour en arrière
        ),
        toolbarHeight: 120,
        backgroundColor: vertMoyen,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Edition/Création d’un circuit",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/logoSansFond.png',
                  height: 80,
                ),
              ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    zoneSupprCircuitBouton(),
                    zoneText("Informations du circuit"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        zoneText("Nom du circuit"),
                        SizedBox(height: 8),
                        zoneText("Description"),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        zoneText("Points de passage"),
                        zoneCreerPointPassageBouton(),
                      ],
                    ),
                    SizedBox(height: 8),

                    Row(
                      children: [
                        Checkbox(
                          value: _ordrePointPassageActive,
                          onChanged: (bool? value) {
                            setState(() {
                              _ordrePointPassageActive = value ?? false;
                              if (_circuit != null) {
                                _circuit!.setOrdrePointPassage(_ordrePointPassageActive);
                              }
                            });
                          },
                          activeColor: vertMoyen,
                        ),
                        Text(
                          "Ajouter un ordre aux Points de Passages",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4b8c72),
                          ),
                        ),
                      ],
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 20.0),
                          backgroundColor: _ordrePointPassageActive
                              ? const Color(0xFF4b8c72)
                              : Colors.grey,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: _ordrePointPassageActive
                            ? () {
                          enregistrerCircuit();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreerOrdrePointPassagePage(userID: _userID, circuitID: _circuitID),
                            ),
                          );
                        }
                            : null,
                        child: Row(
                          children: [
                            Icon(Icons.swap_vert,
                                color: Colors.white),
                            SizedBox(width: 8),
                            Text("Modifier l'ordre des Points de Passages",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                    buildPointsDePassageGrid(),
                    voirPlusVoirMoins(),
                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 20.0),
                            backgroundColor: const Color(0xFF4b8c72),
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: enregistrerCircuit,
                          child: Row(
                            children: [
                              Icon(Icons.check, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Enregistrer",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
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



  Widget zoneSupprCircuitBouton() {
    return Container(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 5),
            //croix
            ElevatedButton(
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: grisClair,  // Fond gris clair pour l'alerte
                    title: const Text("Suppression du cirucit"),  // Titre de l'alerte
                    content: Text(
                      "Êtes-vous sûr de vouloir supprimer ce circuit ?", // Message de confirmation
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
                          // Action de suppression ici
                          supprimer();
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
                    "supprimer le circuit",
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

  Widget zoneCreerPointPassageBouton() {
    return Container(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 5),
            //croix
            ElevatedButton(
              onPressed: () => {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PointDePassagePage(
                      userID: _userID,
                      circuitID: _circuitID!,
                    ),
                  ),
                ),
              },
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
                    "créer un point de passage",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5ba788),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.add,
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
    if (titre == "Nom du circuit") {
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
                _editTitleTextFieldNom(),
                const SizedBox(height: 2),
                appuiEntrer("Nom"),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    } else if (titre == "Description") {
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
                _editTitleTextFieldDescription(),
                const SizedBox(height: 2),
                appuiEntrer("Description"),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }
    return Container(
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
                      color: Color(0xFF4b8c72),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget appuiEntrer(String qui) {
    if (qui == "Nom" && _isEditingTextNom) {
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
    } else if (qui == "Description" && _isEditingTextDescription) {
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

  //text édit
  Widget _editTitleTextFieldNom() {
    if (_isEditingTextNom) {
      return Container(
        child: TextField(
          style: TextStyle(
            color: vertFonce,
            fontSize: 14,
          ),
          onSubmitted: (newValue) {
            setState(() {
              _circuit!.setNom(newValue);
              initialTextNom = newValue;
              _isEditingTextNom = false;
            });
          },
          autofocus: true,
          controller: _editingControllerNom,
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
            _isEditingTextNom = true;
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
                  initialTextNom!,
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

  Widget _editTitleTextFieldDescription() {
    if (_isEditingTextDescription) {
      return Container(
        child: TextField(
          style: TextStyle(
            color: vertFonce,
            fontSize: 14,
          ),
          onSubmitted: (newValue) {
            setState(() {
              _circuit!.setDescription(newValue);
              initialTextDescription = newValue;
              _isEditingTextDescription = false;
            });
          },
          autofocus: true,
          controller: _editingControllerDescription,
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
            _isEditingTextDescription = true;
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
                  initialTextDescription!,
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

  //Conteneur des points de passage
  Widget buildPointsDePassageGrid() {
    //aucuns points de passage
    if (_lstWidgetPointPassage.length == 0) {
      return Container(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 10),
                Icon(
                  Icons.mood_bad,
                  color: vertClair,
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                  "Aucuns point de passage n'est attribué à ce circuit",
                  style: TextStyle(
                    fontSize: 13,
                    color: vertClair,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    }
    //si il y a 3 points de passage ou MOINS
    //on affiche tout les points de passage
    if (_lstWidgetPointPassage.length <= 3) {
      return Container(
        height: cardHeight * _lstWidgetPointPassage.length,
        child: Column(
          children: [
            affichePointsDePassage(false),
          ],
        ),
      );
    }
    //si il y a 3 points de passage ou PLUS
    if (_lstWidgetPointPassage.length > 3) {
      //on affiche tout les points de passage
      if (visiblePointPassage > 3) {
        return Container(
          height: cardHeight * _lstWidgetPointPassage.length,
          child: Column(
            children: [
              affichePointsDePassage(false),
            ],
          ),
        );
      }
      //on affiche que les 3 premiers points de passage
      return Container(
        height: cardHeight * 3,
        child: Column(
          children: [affichePointsDePassage(true)],
        ),
      );
    }
    return Text("data");
  }

  ///si affichePetit est true alors on doit afficher 3 points de passage, tous sinon
  Widget affichePointsDePassage(bool affichePetit) {
    if (affichePetit) {
      return Container(
        child: Column(
          children: [
            _lstWidgetPointPassage[0],
            _lstWidgetPointPassage[1],
            _lstWidgetPointPassage[2],
          ],
        ),
      );
    }
    //affiche tout les points de passages existants
    return ListView(
      shrinkWrap: true, // Important pour une ListView imbriquée
      physics: NeverScrollableScrollPhysics(),
      children: _lstWidgetPointPassage.toList(),
    );
  }

  Widget voirPlusVoirMoins() {
    //si il y a plus de 3 points de passage
    if (_lstWidgetPointPassage.length > 3) {
      //si actuellement il y en a 3 d'affichés
      //alors on affiche bouton voir plus qui rend visible tout les points de passage existants
      if (visiblePointPassage == 3) {
        return Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(20, 20),
                foregroundColor: vertClair,
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 20.0),
              ),
              onPressed: () {
                setState(() {
                  visiblePointPassage = _lstWidgetPointPassage.length;
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
                      color: Color(0xFF4b8c72),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
      //si actuellement il y en a + de 3 d'affichés
      //alors on affiche bouton voir moins qui rend visible seulement 3 points de passage
      if (visiblePointPassage > 3) {
        return Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(20, 20),
                foregroundColor: vertClair,
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 20.0),
              ),
              onPressed: () {
                setState(() {
                  visiblePointPassage = 3;
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
    }
    return Container();
  }

  Widget passageCard(String pointPassageID, String title, String description,
      String qrCode,
      int errorsAllowed) {
    return Container(
      height: cardHeight,
      padding: EdgeInsets.only(bottom: 0.0, left: 10, right: 10),
      // Padding de 10px pour la dernière carte
      child: Card(
        color: const Color(0xFF4b8c72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Informations du point de passage
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Nombre d'erreurs autorisées: $errorsAllowed",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  //boutons editer/supprimer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //bouton editer
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PointDePassagePage(
                                userID: _userID,
                                circuitID: _circuitID!,
                                pointPassageID: pointPassageID,
                              ),
                            ),
                          );
                        }, // Action pour éditer
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
                            //icon time
                            Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 35,
                            ),

                            //temps
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

                      //bouton editer
                      ElevatedButton(
                        onPressed: () {
                          // Affichage de la boîte de dialogue de confirmation avant suppression
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor:
                              grisClair, // Fond gris clair pour l'alerte
                              title: const Text(
                                  "Suppression du point de passage"), // Titre de l'alerte
                              content: Text(
                                "Êtes-vous sûr de vouloir supprimer ce point de passage ?", // Message de confirmation
                              ),
                              actions: [
                                // Bouton "Non" pour annuler
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // Ferme la boîte de dialogue sans rien faire
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white, // Fond blanc
                                    foregroundColor: Colors.black, // Texte noir
                                  ),
                                  child: const Text("Non"), // Texte du bouton
                                ),
                                // Bouton "Oui" pour confirmer la suppression
                                TextButton(
                                  onPressed: () {
                                    // Action de suppression ici
                                    supprimerPointPassage(
                                        pointPassageID); // Appel de la fonction pour supprimer la partie
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AccueilWeb(userID: _userID)));
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white, // Fond blanc
                                    foregroundColor: Colors.black, // Texte noir
                                  ),
                                  child: const Text("Oui"), // Texte du bouton
                                ),
                              ],
                            ),
                          );
                        }, // Action pour éditer
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
                            //icon time
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 35,
                            ),

                            //temps
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
}
