import 'package:flutter/material.dart';
import 'package:tracks/pagesWeb/14_partieEstLancee.dart';

import '../back/partie.dart';

const Color vertMoyen = Color(0xFF4b8c72);

class Lancementpartie extends StatefulWidget {
  final Partie partie;
  final String userID;
  const Lancementpartie({super.key, required this.partie, required this.userID});

  @override
  _Lancementpartie createState() => _Lancementpartie(partie, userID);
}

int visibleCircuits = 1; // Nombre de circuits visibles initialement
int malus = 120; // Initialisation du malus
int nombreGroupes = 6; // Initialisation du nombre de groupes

class _Lancementpartie extends State<Lancementpartie> {
  Partie _partie;
  String _userID;

  _Lancementpartie(this._partie, this._userID);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe9e9e9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white, //couleur de la flèche retour en arrière
        ),
        toolbarHeight: 120,
        backgroundColor: vertMoyen,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Lancement d’une partie",
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
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            buildSectionTitle(context, _partie.getNom()),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 20.0),
                    textStyle: const TextStyle(fontSize: 14),
                    backgroundColor: vertMoyen,
                  ),
                  onPressed: () {
                    // Function to save the information
                    _partie.setEstLancee(true);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Page14(partie: _partie, userID: _userID,)),
                    );

                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 8),
                      Text(
                        "Lancer la partie",
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // List of Points de passage
          ],
        ),
      ),
    );
  }
}

Widget buildSectionTitle(BuildContext context, String title) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: vertMoyen,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildCircuitCard(
    String circuit, String description, List<String> pointsDePassage,
    {bool isLast = false}) {
  return Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0.0 : 0.0, left: 0, right: 0),
    child: Card(
      color: vertMoyen,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  circuit,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  width: 400,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    pointsDePassage.map((point) => Text(point)).toList(),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.file_download_rounded),
                          color: Colors.white,
                          iconSize: 50,
                          onPressed: () {}, // Action pour éditer
                        ),
                        Text(
                          "QR codes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye_outlined),
                          color: Colors.white,
                          iconSize: 50,
                          onPressed: () {}, // Action pour ajouter
                        ),
                        Text(
                          "Voir",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
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