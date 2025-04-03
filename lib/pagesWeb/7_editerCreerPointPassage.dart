import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracks/back/circuit.dart';
import 'package:tracks/back/pointpassage.dart';
import 'package:tracks/back/enigmeText.dart';
import 'package:tracks/back/enigmeImage.dart';
import 'package:tracks/pagesWeb/6_editerCreerCircuit.dart';
import 'package:tracks/pagesWeb/8_enigmesExistantes.dart';
import 'package:tracks/pagesWeb/tracksFooter.dart';

import '16_editerCreerEnigmeText.dart';
import '4_accueil.dart';

//Color(0xFF3c735d) vert foncé
//Color(0xFF4b8c72) vert moyen
//Color(0xFF5ba788) vert clair

//Color(0xFFd9d9d9) gris clair

class PointDePassagePage extends StatefulWidget {
  final String userID;
  final String circuitID;
  final String pointPassageID;
  PointDePassagePage({
    super.key,
    required this.userID,
    this.circuitID = "",
    this.pointPassageID = "",
  });

  @override
  _PointDePassagePageState createState() =>
      _PointDePassagePageState(userID, circuitID, pointPassageID);
}

class _PointDePassagePageState extends State<PointDePassagePage> {
  //Constructeur
  final String _userID;
  String _mailUser = "";
  String? _pointPassageID;
  String? _circuitID;
  _PointDePassagePageState(this._userID, this._circuitID, this._pointPassageID);

  //Variables
  int _selectedValue = 0;
  bool _finChargement = false;
  bool _enigmeAssociee=false;
  PointPassage? _pointPassage=null;
  EnigmeText? _enigmeText=null;
  EnigmeImage? _enigmeImage = null;
  List<String>? _userLstEnigme = [];

  Widget _widgetEnigme = Container();



  //variables texte éditable
  bool _isEditingTextNom = false;
  bool _isEditingTextDescription = false;
  bool _isEditingTextReponse = false;
  late TextEditingController _editingControllerNom;
  late TextEditingController _editingControllerDescription;
  late String? initialTextNom;
  late String? initialTextDescription;
  double tailleTextEdit = 400;

  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);
  static const Color grisClair = Color(0xFFe9e9e9);

  @override
  void initState() {
    initialTextNom = "";
    initialTextDescription = "";
    super.initState();
    getUserData();
  }

  ///récupère les données de l'utilisateur et lance la suite de l'initialisation
  ///
  /// lance [creerPointPassageBD] si un ID de point de passage est passé en paramètre du constructeur de la classe PointDePassagePage
  /// lance [creerPointPassageBD] si aucun ID de point de passage est passé en paramètre du constructeur de la classe PointDePassagePage
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
      try {
        _userLstEnigme = user['lstEnigme'] is Iterable
            ? List.from(user['lstEnigme'])
            : null;
      } catch (e) {
        _userLstEnigme = [];
      }
    });
    if (_pointPassageID!.length == 0) {
      creerPointPassageBD();
    } else {
      print("getPointPassage :" + _pointPassageID!);
      getPointPassage();
    }
  }

  ///Récupère le point de passage dont l'id est [_pointPassageID].
  ///
  /// Initialise les variables de sauvegarde
  Future<void> getPointPassage() async {
    final ref = FirebaseFirestore.instance
        .collection("pointPassage")
        .doc(_pointPassageID)
        .withConverter(
          fromFirestore: PointPassage.fromFirestore,
          toFirestore: (PointPassage pointPassage, _) =>
              pointPassage.toFirestore(),
        );
    final docSnap = await ref.get();
    setState(() {
      _pointPassage = docSnap.data();
    });
    getEnigme();
  }


  ///Récupère les données de l'énigme liée au point de passage [_pointPassage]
  ///
  /// Teste si [_pointPassage] possède une énigme
  /// si oui récupère les données et les enregistre dans [_enigmeText] ou dans [_enigmeImage] selon le type d'énigme
  /// puis appèle Enigme.affiche() pour construire [_widgetEnigme]
  /// si non alors construit le widget [_widgetEnigme]
  Future<void> getEnigme() async {
    print("editerCreerPointPassage getEnigme"+ _pointPassage!.getEnigme()!.isEmpty.toString());
    if (!_pointPassage!.getEnigme()!.isEmpty) {
      _enigmeAssociee=true;
      print("editerCreerPointPassage getEnigme if 1");
      final enigmeGlobal = await FirebaseFirestore.instance.collection("Enigme")
          .doc(_pointPassage!.getEnigme()).get()
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
            .doc(_pointPassage!.getEnigme())
            .withConverter(
          fromFirestore: EnigmeImage.fromFirestore,
          toFirestore: (EnigmeImage enigme, _) =>
              enigme.toFirestore(),
        ).get();
        setState(() {
          _enigmeImage = enigme.data();
          _widgetEnigme = _enigmeImage!.affiche();
        });
      } else if (enigmeGlobal["type"] == "EnigmeText") {
        print("editerCreerPointPassage getEnigmeText");
        final enigme = await FirebaseFirestore.instance
            .collection("EnigmeText")
            .doc(_pointPassage!.getEnigme())
            .withConverter(
          fromFirestore: EnigmeText.fromFirestore,
          toFirestore: (EnigmeText enigme, _) =>
              enigme.toFirestore(),
        ).get();
        setState(() {
          _enigmeText = enigme.data();
          _widgetEnigme = _enigmeText!.affiche();
        });
      }else{
        setState(() {
            _widgetEnigme=Container(
                child:  Row(
                  children: [
                    Text("Pas d'énigmes associée"),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: vertMoyen,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditionCreationEnigmeText(
                              userID: _userID, pointPassageID: _pointPassageID!, circuitID: _circuitID!,provenance: "editPointPassage",
                            ),
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cached,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Ajouter une énigme",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            );
          });
      }
    }
    initTextEdit();
  }

  ///Crée un nouveau point de passage dans la base de donnée
  ///
  /// Si [_circuitID] contient une ID alors l'ID du point de passage est ajouté dans la liste correspondante dans le circuit
  Future<void> creerPointPassageBD() async {
    print("creerPointPassageBD");
    print("id Circuit : "+_circuitID!);
    PointPassage pointPassage = await PointPassage.createPointPassage(
        "Nouveau Point de Passage", "Description");
    setState(() {
      _pointPassage = pointPassage;
      _pointPassageID = _pointPassage!.getID();
    });
    if (_circuitID!.length != 0) {
      final ref = await FirebaseFirestore.instance
          .collection("circuit")
          .doc(_circuitID)
          .withConverter(
            fromFirestore: Circuit.fromFirestore,
            toFirestore: (Circuit circuit, _) => circuit.toFirestore(),
          );
      final docSnap = await ref.get();
      Circuit? circuit = docSnap.data();
      circuit!.ajouterPointPassage(_pointPassage!.getID());
      print(circuit.getLstPointPassage().toString());
    }
    initTextEdit();
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

  ///Initialise les variables liées aux textes éditables
  ///Initialise les variables liées aux textes éditables
  void initTextEdit() {
    setState(() {
      initialTextDescription = _pointPassage!.getDescription()!;
      initialTextNom = _pointPassage!.getNom()!;

      _editingControllerNom = TextEditingController(text: initialTextNom);
      _editingControllerDescription = TextEditingController(text: initialTextDescription);

      _finChargement = true;
    });

  }


  ///Construit les boutons de naviagetion nécessaires à l'énigme.
  Widget buildWidgetBoutonEnigme(){
    print("buildWidgetEnigme");
    if (_enigmeAssociee && _finChargement){
      return Container(
          child:  Row(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                  vertical: 20.0, horizontal: 20.0),
              textStyle: const TextStyle(fontSize: 16),
              backgroundColor: vertMoyen,
            ),
            onPressed: () {
              enregistrerPointPassage(1);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>  EnigmesExistantes(userID: _userID, pointPassageID: _pointPassageID!, circuitID: _circuitID!,)
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.cached,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Changer l'énigme",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                  vertical: 20.0, horizontal: 20.0),
              textStyle: const TextStyle(fontSize: 16),
              backgroundColor: vertMoyen,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>  EditionCreationEnigmeText(userID: _userID, circuitID: _circuitID!, pointPassageID: _pointPassageID!, enigmeID: _pointPassage!.getEnigme()!, provenance: "editPointPassage",)/*Rediriger vers la banque d'énigme*//*EditionCreationEnigmeText(userID: _userID,),*/
                ),
              );
            },
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit,
                  color: vertClair,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Modifier l'énigme",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      )
      );
    }else if (!_enigmeAssociee && _finChargement){
      print("_pointPassageID : " + _pointPassageID!);
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              Icon(
                Icons.mood_bad,
                color: vertMoyen,
                size: 15,
              ),
              const SizedBox(width: 7),
              const Text(
                "Aucune enigme associée",
                style: TextStyle(
                  fontSize: 13,
                  color: vertMoyen,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 20),
          // Bouton echanger
          ElevatedButton(
            onPressed: () {
              enregistrerPointPassage(1);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20.0),
              backgroundColor: vertMoyen,
              foregroundColor: vertFonce,
              shadowColor: Colors.transparent,
              minimumSize: const Size(1, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(200.0),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 5),
                const Text(
                  "Ajouter une énigme",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }else{
      return Container();
    }
  }


  ///enregistre dans la base de donnée les modifications faites par l'utilisateur
  Future<void> enregistrerPointPassage(int page) async{
    if (_pointPassage!.getNom()!.length == 0) {
      print("Vous devez donner un titre à votre point de passage");
    } else {
      print("enregistrerPointPassage");
      await _pointPassage!.mettreAJourBD();
      switch(page){
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CircuitCreationCircuit(
                  userID: _userID, circuitID: _circuitID!),
            ),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>  EnigmesExistantes(userID: _userID, pointPassageID: _pointPassageID!, circuitID: _circuitID!,)
            ),
          );
          break;
      }
      /*
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CircuitCreationCircuit(
              userID: _userID, circuitID: _circuitID!),
        ),
      );
       */
    }
  }


  ///supprime le point de passage en cours d'édition
  ///
  /// Supprimer le point de passage dans le circuit et dans la base de données
  Future<void> supprimerPointPassage() async {
    final ref = FirebaseFirestore.instance
        .collection("circuit")
        .doc(_circuitID)
        .withConverter(
          fromFirestore: Circuit.fromFirestore,
          toFirestore: (Circuit circuit, _) => circuit.toFirestore(),
        );
    final docSnap = await ref.get();
    Circuit? circuit = docSnap.data();
    circuit!.supprimerPointPassage(_pointPassageID);
    _pointPassage!.supprimerPointPassage();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CircuitCreationCircuit(
          userID: _userID,
          circuitID: _circuitID!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("buildEditerCreerPointPassage");
    return Scaffold(
      backgroundColor: const Color(0xFFd9d9d9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // couleur de la flèche retour en arrière
        ),
        toolbarHeight: 120,
        backgroundColor: const Color(0xFF4b8c72),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 15),
            Text("Création/Edition d’un point de passage",
                style: TextStyle(fontSize: 18, color: Colors.white)),
            Expanded(
              child: Center(
                child: Image.asset('assets/images/logoSansFond.png', height: 80),
              ),
            ),
            const Icon(
              Icons.account_circle_sharp,
              color: Colors.white,
              size: 25,
            ),
            const SizedBox(width: 15),
            Text(_mailUser,
                style: const TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(width: 15),
          ],
        ),
      ),
      body: Column(
        children: [
          // Contenu principal avec ScrollView
          Expanded(
            child: SingleChildScrollView(
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
                          // Titre + Supprimer ce point de passage
                          zoneBoutonSuppr(),
                          const SizedBox(height: 8),

                          // Contenu
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Infos du point de passage
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  zoneText("Informations du point de passage"),
                                  const SizedBox(height: 15),
                                  zoneText("Nom du point de passage"),
                                  const SizedBox(height: 8),
                                  zoneText("Description"),
                                ],
                              ),

                              // Énigme
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  zoneText("Enigme associée"),
                                  const SizedBox(height: 15),
                                  _widgetEnigme,
                                  buildWidgetBoutonEnigme(),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Boutons en bas de la page
                          boutonBasDePage(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TracksFooter(context: context),
        ],
      ),
    );
  }


///Génère le bouton enregistrer
  Widget boutonBasDePage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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
          onPressed: () =>{
            enregistrerPointPassage(0)
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min, // Pour ne pas étendre le bouton
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 5), // Espace entre l'icône et le texte
              Text(
                "Enregistrer",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  /*
  Widget dropDownMenu() {
    return Container(
      width: tailleTextEdit,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nombre d\'erreurs possibles',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4b8c72),
              ),
            ),
            Container(
              width: 60,
              height: 30,
              padding: const EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: vertMoyen,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DropdownButton<int>(
                      style: TextStyle(color: Colors.white, fontSize: 13),
                      value: _selectedValue,
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedValue = newValue!;
                        });
                      },
                      underline: Container(
                        height: 0,
                      ),
                      iconEnabledColor: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      dropdownColor: vertMoyen,
                      items: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            value.toString(),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }*/

  ///Génère les labels puis appèle les fonctions génératrices de text éditable
  ///
  /// [titre] défini le titre et la fonction appelée
  Widget zoneText(String titre) {
    if (titre == "Nom du point de passage") {
      return Container(
        width: tailleTextEdit,
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
        width: tailleTextEdit,
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
    } else if (titre == "Réponse attendue") {
      return Container(
        width: tailleTextEdit,
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
            /*Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _editTitleTextFieldReponse(),
                const SizedBox(height: 2),
                appuiEntrer("Reponse"),
              ],
            ),
            const SizedBox(height: 20),
          */],
        ),
      );
    }
    return Row(
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
      ],
    );
  }


  ///Génère les messages d'avertissement pour la validation des champs
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
    } else if (qui == "Reponse" && _isEditingTextReponse) {
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


  ///Gestion de la zone de texte éditable pour le nom de l'énigme
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
              _pointPassage!.setNom(newValue);
              initialTextNom = newValue;
              _isEditingTextNom = false;
            });
          },
          autofocus: true,
          controller: _editingControllerNom,
          decoration: InputDecoration(
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

  ///Gestion de la zone de texte éditable pour la description de l'énigme
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
              _pointPassage!.setDescription(newValue);
              initialTextDescription = newValue;
              _isEditingTextDescription = false;
            });
          },
          autofocus: true,
          controller: _editingControllerDescription,
          decoration: InputDecoration(
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

  ///Génère le bouton supprimer
  Widget zoneBoutonSuppr() {
    return Container(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 5),

            //croix
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: grisClair,  // Fond gris clair pour l'alerte
                    title: const Text("Suppression du point de passage"),  // Titre de l'alerte
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
                          backgroundColor: Colors.white,  // Fond blanc
                          foregroundColor: Colors.black,   // Texte noir
                        ),
                        child: const Text("Non"),  // Texte du bouton
                      ),
                      // Bouton "Oui" pour confirmer la suppression
                      TextButton(
                        onPressed: () {
                          supprimerPointPassage();
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
                    "Supprimer ce point de passage",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5ba788),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.close,
                    color: Color(0xFF3c735d),
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
}
