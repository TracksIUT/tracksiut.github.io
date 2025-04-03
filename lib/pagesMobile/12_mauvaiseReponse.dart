import 'package:flutter/material.dart';
import 'package:tracks/back/chrono.dart'; // Assurez-vous que le chemin est correct
import 'package:tracks/back/enigmeImage.dart';
import 'package:tracks/back/enigmeText.dart';
import 'package:tracks/back/pointpassage.dart';
import 'package:tracks/pagesMobile/10_enigmeText.dart';
import 'package:tracks/pagesMobile/8_scannerQrCodeEnigme.dart';
import 'package:tracks/pagesMobile/9_enigmeImage.dart';
import '../back/circuit.dart';

class Page12 extends StatefulWidget {
  final Circuit circuit;
  final PointPassage pointPassage;
  final String idPartie;
  final String nom;
  final EnigmeText? enigmeText;
  final EnigmeImage? enigmeImage;
  const Page12(
      {super.key,
      required this.circuit,
        required this.pointPassage,
      required this.idPartie,
      required this.nom,
      this.enigmeText,
      this.enigmeImage});

  @override
  State<Page12> createState() => Page12State(circuit, pointPassage, idPartie, nom, enigmeText, enigmeImage);
}

class Page12State extends State<Page12> {
  Circuit _circuit;
  PointPassage _pointPassage;
  String _idPartie;
  String _nom;
  EnigmeText? _enigmeText;
  EnigmeImage? _enigmeImage;
  Page12State(this._circuit, this._pointPassage, this._idPartie, this._nom, this._enigmeText, this._enigmeImage);
  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 210,
        automaticallyImplyLeading: false,
        backgroundColor: vertMoyen, // Vert moyen
        elevation: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logoSansFond.png',
                    width: 150,
                  ),
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
                          color: vertMoyen, // Vert moyen
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
                                color: vertMoyen, // Vert moyen
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
            const Center(
              child: Column(
                children: [
                  Text(
                    "Nom de la partie",
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Nom du groupe",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: vertMoyen,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 300,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Dommage !",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "C'est la mauvaise réponse :(",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final tempsEcoule = _formatTime(
                              chrono.elapsedSeconds); // Formate le temps écoulé
                          if (_enigmeText!=null){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Page10(
                                  enigme: _enigmeText!,
                                  pointPassage: _pointPassage,
                                  circuit: _circuit,
                                  idPartie: _idPartie,
                                  nom: _nom,
                                ),
                              ),
                            );
                          }else if (_enigmeImage != null){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Page9(
                                  enigme: _enigmeImage!,
                                  pointPassage: _pointPassage,
                                  circuit: _circuit,
                                  idPartie: _idPartie,
                                  nom: _nom,
                                ),
                              ),
                            );
                          } else{
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Page8(
                                  circuit: _circuit,
                                  idPartie: _idPartie,
                                  nom: _nom,
                                ), // Passe le temps
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(300, 50),
                        ),
                        child: const Text(
                          "Réessayer",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: vertFonce,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
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
                          backgroundColor: vertClair, // Vert clair
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
