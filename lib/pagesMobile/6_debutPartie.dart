import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracks/back/partie.dart';
import '../back/circuit.dart';
import 'package:tracks/pagesMobile/8_scannerQrCodeEnigme.dart';

import 'package:tracks/back/joueur.dart';

import '7_chercherLieu.dart';

class Page6 extends StatefulWidget{
  final Partie partie;
  final String nom;
  const Page6({super.key, required this.partie, required this.nom});

  @override
  State<StatefulWidget> createState() => _Page6state(partie, nom);
}

class _Page6state extends State<Page6> {
  final Partie _partie;
  late Circuit? _circuit;
  final String _nom;
  bool _partieCommence = false;

  _Page6state(this._partie, this._nom);

  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);

  late String tempPartieID;

  Future<void> _debutPartie() async {
    print("debutPartie()");

    final docRef = FirebaseFirestore.instance
        .collection("partie")
        .doc(_partie.getPartieID());
    final get = docRef.get();
    final partie = await get.then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data["lancee"];
      },
      onError: (e) => print("Error getting document: $e"),
    );
    print(partie);

    if (partie) {
      setState(() {
        _partie.mettreAJourInstance();
      });
      tempPartieID = _partie.getPartieID();
      getCircuitPartie();
    }
  }

  Future<void> getCircuitPartie() async {
    print("getCircuitPartie()");
    final ref = FirebaseFirestore.instance
        .collection("circuit")
        .doc(_partie.getCircuitID())
        .withConverter(
          fromFirestore: Circuit.fromFirestore,
          toFirestore: (Circuit circuit, _) => circuit.toFirestore(),
        );
    final docSnap = await ref.get();
    setState(() {
      _circuit = docSnap.data();
      _partieCommence = true;
    });
    print("partieCommence getCircuit");
    print(_partieCommence);
    if (mounted) {
      if (!_circuit!.getOrdrePointPassage()) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Page8(
                      circuit: _circuit!,
                      idPartie: tempPartieID,
                      nom: _nom,
                    )));
      }else{
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Page7(
                      circuit: _circuit!,
                      idPartie: tempPartieID,
                      nom: _nom,
                    )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        /*iconTheme: IconThemeData(
          color: Colors.white, //couleur de la flèche retour en arrière
        ),*/
        automaticallyImplyLeading: false, //pas de flèche retour en arrière
        backgroundColor: vertMoyen, // Couleur de fond VERT MOYEN
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //a mettre au milieu
            //logo
            Image.asset(
              'assets/images/logoSansFond.png', // Chemin de l'image du logo dans les assets
              width: 150, // Redimensionne l'image
            ),

            //chrono
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
                  //icon time
                  IconButton(
                    icon: const Icon(Icons.timer_outlined),
                    color: vertMoyen, // VERT MOYEN
                    tooltip: 'Temp restant',
                    onPressed: () {},
                  ),

                  //temps
                  const Text(
                    "00:00",
                    style: TextStyle(
                      fontSize: 15,
                      color: vertMoyen, // VERT MOYEN
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),

      body: Container(
        color: vertMoyen, // Couleur de fond VERT MOYEN
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                width: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text(
                        textAlign: TextAlign.center,
                        'Début de la partie ',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          color:
                              Colors.white, // Texte en blanc pour être visible
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        textAlign: TextAlign.center,
                        _partie.getNom(),
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              Colors.white, // Texte en blanc pour être visible
                        ),
                      ),
                      const SizedBox(height: 50),


                      const Text(
                        textAlign: TextAlign.center,
                        "A toi de jouer",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          color:
                              Colors.white, // Texte en blanc pour être visible
                        ),
                      ),
                      const SizedBox(height: 5),

                      Text(
                        textAlign: TextAlign.center,
                        _nom + ' !',
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              Colors.white, // Texte en blanc pour être visible
                        ),
                      ),
                      const SizedBox(height: 50),

                      //bouton page suivante
                      ElevatedButton(
                        onPressed: () {
                          _debutPartie();
                          /*
                            if(fin de partie)
                              MaterialPageRoute(builder: (context) => Page13()), // Navigation vers page fin partie (13)
                            else
                              MaterialPageRoute(builder: (context) => Page(7)), // Navigation vers page cherche lieux (7)
                            */
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          minimumSize:
                              const Size(300, 50), // Largeur: 300, Hauteur: 60
                        ),
                        child: const Text(
                          "Commencer la partie",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color:
                                vertFonce, // Couleur du texte du bouton VERT FONCE
                          ),
                        ),
                      ),
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
