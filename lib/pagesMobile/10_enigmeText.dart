import 'package:flutter/material.dart';
import 'package:tracks/back/chrono.dart';
import 'package:tracks/back/enigmeText.dart';
import 'package:tracks/pagesMobile/11_bonneReponse.dart';
import 'package:tracks/pagesMobile/12_mauvaiseReponse.dart';
import 'package:tracks/pagesMobile/8_scannerQrCodeEnigme.dart';

import '../back/circuit.dart';
import '../back/pointpassage.dart';

class Page10 extends StatefulWidget {
  final Circuit circuit;
  final PointPassage pointPassage;
  final EnigmeText enigme;
  final String idPartie;
  final String nom;
  const Page10(
      {super.key,
      required this.circuit,
      required this.pointPassage,
      required this.enigme,
      required this.idPartie,
      required this.nom});

  @override
  State<Page10> createState() =>
      _Page10State(circuit, pointPassage, enigme, idPartie, nom);
}

class _Page10State extends State<Page10> {
  Circuit _circuit;
  PointPassage _pointPassage;
  EnigmeText _enigme;
  String _idPartie;
  String _nom;
  _Page10State(this._circuit, this._pointPassage, this._enigme, this._idPartie,
      this._nom);

  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);
  static const Color grisClair = Color(0xFFd9d9d9);

  final ChronoManager chrono = ChronoManager();


  bool _isEditingTextReponse = false;
  late TextEditingController _editingControllerReponse;
  late String? initialTextReponse;


  @override
  void initState() {
    initialTextReponse = "";
    super.initState();
    initTextEdit();
  }

  ///Initialise les variables liées aux textes éditables
  ///Initialise les variables liées aux textes éditables
  void initTextEdit() {
    setState(() {
      _editingControllerReponse = TextEditingController(text: initialTextReponse);
    });

  }

  ///fonction dispose modifiée pour les zones de texte éditables
  @override
  void dispose() {
    setState(() {
      _editingControllerReponse.dispose();
    });
    super.dispose();
  }

  String _formatTime(int seconds) {
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void verifReponse(){
    print("verifReponse() : Page10");
    if (_enigme.verificationReponse(initialTextReponse!)){
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (context) => Page11(circuit: _circuit, pointPassage: _pointPassage, idPartie: _idPartie, nom: _nom)
          ),
      );
    }else{
      Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => Page12(circuit: _circuit, pointPassage: _pointPassage, idPartie: _idPartie, nom: _nom, enigmeText: _enigme,)
        ),
      );
    }
  }



  ///Gestion de la zone de texte éditable pour le nom de l'énigme
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
              initialTextReponse = newValue;
              _isEditingTextReponse = false;
            });
          },
          autofocus: true,
          controller: _editingControllerReponse,
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
            _isEditingTextReponse = true;
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


  @override
  Widget build(BuildContext context) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 210,
          automaticallyImplyLeading: false,
          // pas de flèche retour en arrière
          backgroundColor: vertMoyen,
          // Couleur de fond VERT MOYEN
          elevation: 0,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // logo
                    Image.asset(
                      'assets/images/logoSansFond.png',
                      // Chemin de l'image du logo dans les assets
                      width: 150, // Redimensionne l'image
                    ),
                    // chrono
                    ElevatedButton(
                      onPressed: () => print("Click btn chrono"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(10, 10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // icon time
                          IconButton(
                            icon: const Icon(Icons.timer_outlined),
                            color: vertMoyen, // VERT MOYEN
                            tooltip: 'Temps restant',
                            onPressed: () {},
                          ),
                          // chrono dynamique
                          StreamBuilder<int>(
                            stream: chrono.elapsedTimeStream,
                            initialData: chrono.elapsedSeconds,
                            builder: (context, snapshot) {
                              final elapsed = snapshot.data ?? 0;
                              return Text(
                                _formatTime(elapsed),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: vertMoyen, // VERT MOYEN
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Column(
                  children: [
                    Text(
                      _nom,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white, // Texte en blanc pour être visible
                      ),
                    ),
                    const SizedBox(height: 25),
                    // nom du lieu
                    Container(
                      width: 250,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_pin,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _pointPassage.getDescription()!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                color: Colors
                                    .white, // Texte en blanc pour être visible
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  _enigme.getIntituleEnigme()!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    color: vertFonce,
                  ),
                ),
                const SizedBox(width: 5),
                // boutons
                Container(
                  width: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _editTitleTextFieldReponse(),
                        const SizedBox(height: 10),
                        // bouton page suivante
                        ElevatedButton(
                          onPressed: () {
                            verifReponse();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vertClair, // VERT CLAIR
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(300, 50),
                          ),
                          child: const Text(
                            "Envoyer ma réponse",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // bouton abandon
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Page8(
                                        circuit: _circuit,
                                        idPartie: _idPartie,
                                        nom: _nom,
                                      )),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vertFonce, // VERT FONCE
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(300, 50),
                          ),
                          child: const Text(
                            "Abandonner",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
}
