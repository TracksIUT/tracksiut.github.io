import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracks/back/chrono.dart';
import 'package:tracks/back/pointpassage.dart';
import 'package:tracks/pagesMobile/13_finPartie.dart';
import 'package:tracks/pagesMobile/7_chercherLieu.dart';
import 'package:tracks/pagesMobile/8_scannerQrCodeEnigme.dart';
import '../back/circuit.dart';

class Page11 extends StatefulWidget {
  final Circuit circuit;
  final PointPassage pointPassage;
  final String idPartie;
  final String nom;
  const Page11(
      {super.key,
      required this.circuit,
      required this.pointPassage,
      required this.idPartie,
      required this.nom});

  @override
  State<Page11> createState() =>
      Page11State(circuit, pointPassage, idPartie, nom);
}

class Page11State extends State<Page11> {
  Circuit _circuit;
  PointPassage _pointPassage;
  bool _parieTerminer = false;
  String _idPartie;
  String _nom;
  Page11State(this._circuit, this._pointPassage, this._idPartie, this._nom);

  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  final ChronoManager chrono = ChronoManager();

  @override
  void initState() {
    super.initState();
    chrono.startTimer();
  }

  @override
  void dispose() {
    chrono.stopTimer();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void verifPartieTerminer() {
    print("verifPartieTerminer");
    print(_circuit.getLstPointPassage());
    _circuit.supprimerPointPassageSansModifBD(_pointPassage.getID());
    if (_circuit.getLstPointPassage()!.length == 0) {
      chrono.stopTimer();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Page13(
                  circuit: _circuit,
                  tempsEcoule: chrono.toString(),
                  idPartie: _idPartie,
                  nom: _nom,
                )),
      );
      setState(() {
        _parieTerminer = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        automaticallyImplyLeading: false, // Pas de flèche retour en arrière
        backgroundColor: vertMoyen, // Vert moyen
        elevation: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logoSansFond.png',
                    width: 150,
                  ),
                  // Chrono
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
                        IconButton(
                          icon: const Icon(Icons.timer_outlined),
                          color: vertMoyen,
                          tooltip: 'Temps restant',
                          onPressed: () {},
                        ),
                        StreamBuilder<int>(
                          stream: chrono.elapsedTimeStream,
                          initialData: chrono.elapsedSeconds,
                          builder: (context, snapshot) {
                            return Text(
                              _formatTime(snapshot.data ?? 0),
                              style: const TextStyle(
                                fontSize: 15,
                                color: vertMoyen,
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
            // Center(
            //   child: Column(
            //     children: const [
            //       Text(
            //         "Nom de la partie",
            //         style: TextStyle(
            //           fontSize: 15,
            //           fontFamily: 'Poppins',
            //           color: Colors.white,
            //         ),
            //       ),
            //       SizedBox(height: 10),
            //       Text(
            //         "Nom du groupe",
            //         style: TextStyle(
            //           fontSize: 13,
            //           color: Colors.white,
            //         ),
            //       ),
            //       SizedBox(height: 25),
            //     ],
            //   ),
            // ),
            SizedBox(height: 5),
          ],
        ),
      ),
      body: Container(
        color: vertMoyen, // Vert moyen
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.sizeOf(context).height - 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 200),
                              const Text(
                                "Bravo !",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                              // const SizedBox(height: 15),
                              // const Text(
                              //   "C'est la bonne réponse",
                              //   textAlign: TextAlign.center,
                              //   style: TextStyle(
                              //     fontSize: 15,
                              //     color: Colors.white,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          verifPartieTerminer();
                          if (!_parieTerminer) {
                            if (!_circuit!.getOrdrePointPassage()) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Page8(
                                            circuit: _circuit,
                                            idPartie: _idPartie,
                                            nom: _nom,
                                          )));
                            }else{
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Page7(
                                            circuit: _circuit,
                                            idPartie: _idPartie,
                                            nom: _nom,
                                          )));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(300, 50),
                        ),
                        child: const Text(
                          "Suivant",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: vertFonce, // Vert foncé
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
