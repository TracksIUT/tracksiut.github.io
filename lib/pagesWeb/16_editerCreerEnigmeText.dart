import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracks/back/enigmeText.dart';
import 'package:tracks/pagesWeb/7_editerCreerPointPassage.dart';
import 'package:tracks/pagesWeb/8_enigmesExistantes.dart';

class EditionCreationEnigmeText extends StatefulWidget {
  final String userID;
  final String circuitID;
  final String pointPassageID;
  final String enigmeID;
  final String provenance;
  EditionCreationEnigmeText({
    super.key,
    required this.userID,
    required this.provenance,
    this.enigmeID = "",
    this.circuitID = "",
    this.pointPassageID = "",
  });

  @override
  _EditionCreationEnigmeTextState createState() =>
      _EditionCreationEnigmeTextState(userID, enigmeID, circuitID, pointPassageID, provenance);
}

class _EditionCreationEnigmeTextState extends State<EditionCreationEnigmeText> {
  //Constructeur
  final String _userID;
  final String _circuitID;
  final String _pointPassageID;
  final String _provenance;

  String _mailUser = "";
  String? _enigmeID;
  String? _type;

  _EditionCreationEnigmeTextState(this._userID, this._enigmeID, this._circuitID, this._pointPassageID ,this._provenance);

  //Variables
  int _selectedValue = 0;
  EnigmeText? _enigmeText =null;
  List<String>? _userLstEnigme = [];


  //variables texte éditable
  bool _isEditingTextNom = false;
  bool _isEditingTextReponse = false;
  bool _isEditingTextIntitule = false;
  late TextEditingController _editingControllerNom;
  late TextEditingController _editingControllerReponse;
  late TextEditingController _editingControllerIntitule;
  late String? initialTextNom;
  late String? initialTextReponse;
  late String? initialTextIntitule;
  double tailleTextEdit = 400;

  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);
  static const Color grisClair = Color(0xFFe9e9e9);

  @override
  void initState() {
    initialTextNom = "";
    initialTextReponse = "";
    initialTextIntitule="";
    super.initState();
    getUserData();
  }

  ///récupère les données de l'utilisateur et lance la suite de l'initialisation
  ///
  /// lance [creerEnigmeBD] si un ID de point de passage est passé en paramètre du constructeur de la classe PointDePassagePage
  /// lance [creerEnigmeBD] si aucun ID de point de passage est passé en paramètre du constructeur de la classe PointDePassagePage
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
    if (_enigmeID!.length == 0) {
      creerEnigmeBD();
    } else {
      print("getEnigme :" + _enigmeID!);
      getEnigme();
    }
  }

  ///Récupère l'enigme dont l'id est [_enigmeID].
  ///
  ///Initialise les variables de sauvegarde
  Future<void> getEnigme() async {
      if (_userLstEnigme!.contains(_enigmeID)) {
        //verifier de quel type est l'enigme
        final docRef = FirebaseFirestore.instance.collection("Enigme").doc(
            _enigmeID);
        final SnapShot = docRef.get();
        final type = await SnapShot.then(
              (DocumentSnapshot doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data["type"];
          },
          onError: (e) => print("Error getting document: $e"),
        );
        print(type);
        if (type == "EnigmeText") {
          final ref = FirebaseFirestore.instance.collection("EnigmeText").doc(
              _enigmeID).withConverter(
            fromFirestore: EnigmeText.fromFirestore,
            toFirestore: (EnigmeText enigme, _) => enigme.toFirestore(),
          );
          final docSnap = await ref.get();
          setState(() {
            _enigmeText = docSnap.data();
          });
        }
      }else{
        redirection();
      }
    initTextEdit();
  }

  ///Crée une nouvelle enigmeText dans la base de donnée
  ///
  ///
  Future<void> creerEnigmeBD() async {
    _enigmeText = await EnigmeText.createEnigmeText(
        "EnigmeText", "intitule", "reponseAttendue");
    setState(() {
      _userLstEnigme!.add(_enigmeText!.getEnigmeID()!);
    });
    final data = <String, dynamic>{
      'lstEnigme' : _userLstEnigme,
    };
    FirebaseFirestore.instance.collection("users").doc(_userID).update(data);
    initTextEdit();
  }

  void redirection(){
    if (_provenance=="BanqueEnigme"){
      Navigator.pushReplacement(context,
        MaterialPageRoute(
          builder: (context) => EnigmesExistantes(userID: _userID, circuitID: _circuitID, pointPassageID: _pointPassageID,),
        ),
      );
    }else if (_provenance=="editPointPassage"){
      Navigator.pushReplacement(context,
        MaterialPageRoute(
          builder: (context) => PointDePassagePage(userID: _userID, circuitID: _circuitID, pointPassageID: _pointPassageID,),
        ),
      );
    }else{
      print("erreur");
    }

  }

  ///fonction dispose modifiée pour les zones de texte éditables
  @override
  void dispose() {
    setState(() {
      _editingControllerNom.dispose();
      _editingControllerReponse.dispose();
      _editingControllerIntitule.dispose();
    });
    super.dispose();
  }

  ///Initialise les variables liées aux textes éditables
  ///Initialise les variables liées aux textes éditables
  void initTextEdit() {
    setState(() {
      initialTextIntitule = _enigmeText!.getIntituleEnigme();
      initialTextReponse = _enigmeText!.getReponseAttendue();
      initialTextNom = _enigmeText!.getNomEnigme();

      _editingControllerNom = TextEditingController(text: initialTextNom);
      _editingControllerReponse = TextEditingController(text: initialTextReponse);
      _editingControllerIntitule = TextEditingController(text: initialTextIntitule);
    });
  }

  ///enregistre dans la base de donnée les modifications faites par l'utilisateur
  Future<void> enregistrerEnigme() async {
    if (_enigmeText!.getNomEnigme()!.length == 0) {
      print("Vous devez donner un titre à votre enigme");
    } else {
      print("enregistrerEnigme");
      await _enigmeText!.mettreAJourBD();
      redirection();
    }
  }


  ///supprime le point de passage en cours d'édition
  ///
  /// Supprimer le point de passage dans le circuit et dans la base de données
  Future<void> supprimer() async {
    // final ref = FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(_enigmeID)
    //     .withConverter(
    //   fromFirestore: Circuit.fromFirestore,
    //   toFirestore: (Circuit circuit, _) => circuit.toFirestore(),
    // );
    // final docSnap = await ref.get();
    // Circuit? circuit = docSnap.data();
    // circuit!.supprimerPointPassage(_enigme);
    // _enigme!.supprimerPointPassage();
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Pointspassageexistants(
    //       userID: _userID,
    //       circuitID: _enigmeID!,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    print("buildEditerCreerEnigme");
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
            Text("Création/Edition d’un point de passage",
                style: TextStyle(fontSize: 18, color: Colors.white)),
            Expanded(
              child: Center(
                child:
                Image.asset('assets/images/logoSansFond.png', height: 80),
              ),
            ),
            Icon(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
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
                    //Titre + Supprimer cette enigme
                    zoneBoutonSuppr(),
                    SizedBox(height: 8),

                    //contenu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //info de l'enigme
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            zoneText("Enigme"),
                            SizedBox(height: 15),
                            zoneText("Intitule"),
                            SizedBox(height: 8),
                            zoneText("Réponse attendue"),
                            SizedBox(height: 8),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    //boutons en bas de la page
                    boutonBasDePage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget boutonBasDePage() {
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
          onPressed: enregistrerEnigme,
          child: const Row(
            mainAxisSize:
            MainAxisSize.min, // Pour ne pas étendre le bouton
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

  Widget zoneText(String titre) {
    print("titre : "+titre);
    if (titre == "Intitule") {
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
                      "Intitule de l'énigme",
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
                _editTitleTextFieldIntitule(),
                const SizedBox(height: 2),
                appuiEntrer("Intitule"),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }else if (titre == "Enigme") {
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
                      "Enigme",
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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _editTitleTextFieldReponse(),
                const SizedBox(height: 2),
                appuiEntrer("Reponse"),
              ],
            ),
            const SizedBox(height: 20),
          ],
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

  Widget appuiEntrer(String qui) {
    if (qui == "Intitule" && _isEditingTextIntitule) {
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
    }else if (qui == "Nom" && _isEditingTextNom) {
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
              _enigmeText!.setNomEnigme(newValue);
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

  Widget _editTitleTextFieldReponse() {
    if (_isEditingTextReponse) {
      return Container(
        child: TextField(
          style: TextStyle(
            color: vertFonce,
            fontSize: 14,
          ),
          onSubmitted: (newValue) {
            setState(() {
              _enigmeText!.setReponseAttendue(newValue);
              initialTextReponse = newValue;
              _isEditingTextReponse = false;
            });
          },
          autofocus: true,
          controller: _editingControllerReponse,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            focusedBorder: OutlineInputBorder(
              borderSide: new BorderSide(color: Colors.white),
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
            _isEditingTextReponse = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  initialTextReponse!,
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

  Widget _editTitleTextFieldIntitule() {
    if (_isEditingTextIntitule) {
      return Container(
        child: TextField(
          style: TextStyle(
            color: vertFonce,
            fontSize: 14,
          ),
          onSubmitted: (newValue) {
            setState(() {
              _enigmeText!.setIntituleEnigme(newValue);
              initialTextIntitule = newValue;
              _isEditingTextIntitule = false;
            });
          },
          autofocus: true,
          controller: _editingControllerIntitule,
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
            _isEditingTextIntitule = true;
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
                  initialTextIntitule!,
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


  Widget zoneBoutonSuppr() {
    return Container(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 5),

            //croix
            ElevatedButton(
              onPressed: () {}, // Action pour éditer l'image enigme
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
                    "Supprimer cette enigme",
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