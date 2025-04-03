import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracks/qrcode/qrcodescanner.dart';
import '../back/circuit.dart';
import '../back/enigme.dart';
import '../back/pointpassage.dart';
import '8_scannerQrCodeEnigme.dart';
import '10_enigmeText.dart';
import 'package:tracks/back/chrono.dart';

class Page7 extends StatefulWidget {
  final Circuit circuit;
  final String idPartie;
  final String nom;

  const Page7({super.key, required this.circuit, required this.idPartie, required this.nom});

  @override
  State<Page7> createState() => _Page7State();
}

class _Page7State extends State<Page7> {
  late Circuit _circuit;
  String _nomPointPassage="";
  List<String> _scannedPoints = [];

  static const Color vertMoyen = Color(0xFF4b8c72);
  final ChronoManager chrono = ChronoManager();
  String? _result;

  @override
  void initState() {
    super.initState();
    _circuit = widget.circuit;
    getPointPassage();
  }

  Future<void> getPointPassage()async {
    final ref = FirebaseFirestore.instance
        .collection("pointPassage")
        .doc(_circuit.getLstPointPassage()![0])
        .withConverter(
      fromFirestore: PointPassage.fromFirestore,
      toFirestore: (PointPassage pointPassage, _) =>
          pointPassage.toFirestore(),
    );
    final docSnap = await ref.get();
    setState(() {
      _nomPointPassage=docSnap.data()!.getNom()!;
    });
  }

  /// Formate le temps en mm:ss
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

                        // temps
                        StreamBuilder<int>(
                          stream: chrono.elapsedTimeStream,
                          initialData: chrono.elapsedSeconds,
                          builder: (context, snapshot) {
                            return Text(
                              _formatTime(snapshot.data ?? 0),
                              style: const TextStyle(
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
                    widget.nom,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white, // Texte en blanc pour être visible
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),

      body: _buildScannerBody(),
    );
  }

  Widget _buildScannerBody() {
    return Container(
      color: vertMoyen, // Couleur de fond VERT MOYEN
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // texte
            Container(
              width: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "A toi de trouver :",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white, // Texte en blanc pour être visible
                      ),
                    ),
                    const SizedBox(height: 15),

                    // nom du lieu
                    Container(
                      width: 250,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:  [
                            Icon(
                              Icons.location_pin,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              _nomPointPassage,
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
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Page8(
                              circuit: _circuit,
                              idPartie: widget.idPartie,
                              nom: widget.nom,
                            )));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shadowColor: Colors.transparent,
                minimumSize: const Size(300, 50), // Largeur: 300, Hauteur: 60
              ),
              child: const Text(
                "Commencer à chercher",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: vertMoyen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
