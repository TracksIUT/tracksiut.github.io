
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracks/back/pointpassage.dart';
import '../back/circuit.dart';
import '../back/enigme.dart';
import '../back/enigmeImage.dart';
import '../back/enigmeText.dart';
import '../qrcode/qrcodescanner.dart';
import '10_enigmeText.dart';
import '11_bonneReponse.dart';
import '7_chercherLieu.dart';
import '9_enigmeImage.dart';
import 'package:tracks/back/partie.dart';

//Color(0xFF3c735d) vert foncé
//Color(0xFF4b8c72) vert moyen
//Color(0xFF5ba788) vert clair

//Color(0xFFd9d9d9) gris clair

class Page8 extends StatefulWidget {
  final Circuit circuit;
  final String idPartie;
  final String nom;
  const Page8(
      {super.key,
      required this.circuit, required this.idPartie, required this.nom});

  @override
  State<Page8> createState() => _Page8State(circuit, idPartie, nom);
}

class _Page8State extends State<Page8> {
  Circuit _circuit;
  String _idPartie;
  String _nom;

  String? _result;
  Enigme? _enigme;
  EnigmeImage? _enigmeImage;
  EnigmeText? _enigmeText;
  PointPassage? _pointPassage;
  Partie? _partie;

  _Page8State(this._circuit, this._idPartie, this._nom);

  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);


  void setResult(String result) {
    setState(() => _result = result);
    //la fonction qui enregistre les données du qr code scanné dans _result
  }

  Future<void> verifPointPassage(String idPointPassageNonVerifier) async {
    if (_circuit.getOrdrePointPassage()){
      if (_circuit.getLstPointPassage()![0]==idPointPassageNonVerifier){
        final ref = FirebaseFirestore.instance
            .collection("pointPassage")
            .doc(idPointPassageNonVerifier)
            .withConverter(
          fromFirestore: PointPassage.fromFirestore,
          toFirestore: (PointPassage pointPassage, _) =>
              pointPassage.toFirestore(),
        );
        final docSnap = await ref.get();
        setState(() {
          _pointPassage = docSnap.data();
        });

        if (_pointPassage != null) {
          print(_pointPassage!.getEnigme());
          if (_pointPassage!.getEnigme()!.length == 0) {
            _result = "";
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Page11(
                      circuit: _circuit,
                      pointPassage: _pointPassage!,
                      idPartie: _idPartie,
                      nom: _nom,
                    )) // Navigation
            );
          } else {
            print("else");
            recupererEnigme();
          }
        }
      }
    }else{
      List<dynamic> listPointPassage = _circuit.getLstPointPassage()!;
      for (int i=0; i<listPointPassage.length; i++){
        if (listPointPassage[i]==idPointPassageNonVerifier){
          final ref = FirebaseFirestore.instance
              .collection("pointPassage")
              .doc(idPointPassageNonVerifier)
              .withConverter(
            fromFirestore: PointPassage.fromFirestore,
            toFirestore: (PointPassage pointPassage, _) =>
                pointPassage.toFirestore(),
          );
          final docSnap = await ref.get();
          setState(() {
            _pointPassage = docSnap.data();
          });

          if (_pointPassage != null) {
            print(_pointPassage!.getEnigme());
            if (_pointPassage!.getEnigme()!.length == 0) {
              _result = "";
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Page11(
                        circuit: _circuit,
                        pointPassage: _pointPassage!,
                        idPartie: _idPartie,
                        nom: _nom,
                      )) // Navigation
              );
            } else {
              recupererEnigme();
            }
          }
        }
      }

    }
  }

  Future<void> recupererEnigme() async {
    print("_pointPassage!.getEnigme() : " + _pointPassage!.getEnigme().toString());
    print("recupererEnigme()");
    final enigmeGlobal = await FirebaseFirestore.instance.collection("Enigme")
        .doc(_pointPassage!.getEnigme()).get()
        .then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data;
      },
      onError: (e) => print("Error getting document: $e"),
    );
    print("test");
    //Si on rencontre des pblms avec le polymorphisme, récupérer complètement et créer uen instance de Enigme et faire la suite dans les autre pages
    if (enigmeGlobal["type"] == "EnigmeImage") {
      print("enigme == EnigmeImage");
      final ref = FirebaseFirestore.instance
          .collection("EnigmeImage")
          .doc(_pointPassage!.getEnigme())
          .withConverter(
            fromFirestore: EnigmeImage.fromFirestore,
            toFirestore: (EnigmeImage enigme, _) => enigme.toFirestore(),
          );
      final docSnap = await ref.get();
      setState(() {
        _enigmeImage = docSnap.data();
      });
      _result = "";
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Page9(
                    circuit: _circuit,
                    pointPassage: _pointPassage!,
                    enigme: _enigmeImage!,
                    idPartie: _idPartie,
                    nom: _nom,
                  )) // Navigation
          );
    } else if (enigmeGlobal["type"] == "EnigmeText") {
      print("enigme == EnigmeText");
      final ref = FirebaseFirestore.instance
          .collection("EnigmeText")
          .doc(_pointPassage!.getEnigme())
          .withConverter(
            fromFirestore: EnigmeText.fromFirestore,
            toFirestore: (EnigmeText enigme, _) => enigme.toFirestore(),
          );
      final docSnap = await ref.get();
      setState(() {
        _enigmeText = docSnap.data();
      });
      _result = "";
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Page10(
                    circuit: _circuit,
                    pointPassage: _pointPassage!,
                    enigme: _enigmeText!,
                    idPartie: _idPartie,
                    nom: _nom,
                  )) // Navigation
          );
    }
    // getPartie();
  }
  //
  // Future<void> getPartie() async {
  //   print("getPartie");
  //   final ref = FirebaseFirestore.instance.collection("partie").doc(_idPartie).withConverter(
  //     fromFirestore: Partie.fromFirestore,
  //     toFirestore: (Partie partie, _) => partie.toFirestore(),
  //   );
  //   final docSnap = await ref.get();
  //   final partie = docSnap.data();
  //   setState(() {
  //     _partie=partie;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (_result != null && _result!.length > 20 && _result?[0] == 'e') {
      verifPointPassage(_result!.substring(1));
      //return Scaffold();
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        iconTheme: IconThemeData(
          color: Colors.white, //couleur de la flèche retour en arrière
        ),
        //automaticallyImplyLeading: false, //pas de flèche retour en arrière
        backgroundColor: Color(0xFF4b8c72), // Couleur de fond VERT MOYEN
        elevation: 0,
      ),
      body: Container(
        color: vertMoyen, // Couleur de fond VERT MOYEN
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //"appBar"
                      Container(
                        width: 330,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    //logo
                                    Image.asset(
                                      'assets/images/logoSansFond.png',
                                      // Chemin de l'image du logo dans les assets
                                      width: 150, // Redimensionne l'image
                                    ),

                                    //chrono
                                    ElevatedButton(
                                      onPressed: () =>
                                          print("Click btn chrono"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        minimumSize: const Size(10, 10),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          //icon time
                                          IconButton(
                                            icon: const Icon(
                                                Icons.timer_outlined),
                                            color: Color(0xFF4b8c72),
                                            // VERT MOYEN
                                            tooltip: 'Temp restant',
                                            onPressed: () {},
                                          ),

                                          //temps
                                          const Text(
                                            "00:00",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Color(
                                                  0xFF4b8c72), // VERT MOYEN
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //
                              // //infos de la partie
                              // Center(
                              //   child: Column(
                              //     children: [
                              //       const Text(
                              //         _partie.getNom(),
                              //         style: TextStyle(
                              //           fontSize: 15,
                              //           fontFamily: 'Poppins',
                              //           color: Colors
                              //               .white, // Texte en blanc pour être visible
                              //         ),
                              //       ),
                              //       const SizedBox(height: 5),
                              //
                              //       const Text(
                              //         "Nom du groupe",
                              //         style: TextStyle(
                              //           fontSize: 13,
                              //           color: Colors
                              //               .white, // Texte en blanc pour être visible
                              //         ),
                              //       ),
                              //       const SizedBox(height: 10),
                              //
                              //       //nom du lieu
                              //       Container(
                              //         width: 250,
                              //         child: Center(
                              //           child: Row(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.center,
                              //             children: [
                              //               const Icon(
                              //                 Icons.location_pin,
                              //                 color: Colors.white,
                              //               ),
                              //               const SizedBox(width: 5),
                              //               const Text(
                              //                 "Nom du lieu",
                              //                 textAlign: TextAlign.center,
                              //                 style: TextStyle(
                              //                   fontSize: 18,
                              //                   fontFamily: 'Poppins',
                              //                   color: Colors
                              //                       .white, // Texte en blanc pour être visible
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),

                      //contenu
                      Container(
                        width: 300,
                        height: MediaQuery.sizeOf(context).height - 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              const SizedBox(height: 90),
                              const Text(
                                "Cherche",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),

                              ElevatedButton(
                                onPressed: () {
                                  // Utilisation de Navigator pour naviguer
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => QrCodeScanner(
                                              setResult: setResult,
                                            )), // Navigation
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  minimumSize:
                                  const Size(300, 50), // Largeur: 300, Hauteur: 60
                                ),
                                child: const Text(
                                  "Scanner un Qr code",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color:
                                    vertFonce, // Couleur du texte du bouton VERT FONCE
                                  ),
                                ),
                              ),

                              // Espacement avant le QR code

                              //bouton page suivante TEMPORAIRE A ENLEVER LORS DU FONCTIONNEMENT DU SCAN QR CODE MARCHE

                              /*ElevatedButton(
                                onPressed: () {
                                  // Utilisation de Navigator pour naviguer
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) =>
                                        Page9(circuit: _circuit,)), //Navigation //Page9()
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shadowColor: Colors.transparent,
                                  minimumSize: const Size(
                                      300, 50), // Largeur: 300, Hauteur: 60
                                ),
                                child: const Text(
                                  "Voir autre page (bouton temporaire)",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .white, // Couleur du texte du bouton VERT FONCE
                                  ),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                      ), //contenu
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
