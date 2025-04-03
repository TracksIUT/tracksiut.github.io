import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracks/pagesWeb/12_profile.dart';
import 'package:tracks/pagesWeb/4_accueil.dart';

import '../back/partie.dart';

class Classement extends StatefulWidget {
  final String userID;
  final Partie partie;

  Classement({super.key, required this.userID, required this.partie});

  @override
  State<StatefulWidget> createState() => _Classement(userID,partie);
}

class _Classement extends State<Classement> {
  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);
  static const Color grisClair = Color(0xFFd9d9d9);

  final String _userID;
  Partie _partie;
  String _mailUser = "";

  _Classement(this._userID, this._partie);

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  /// Récupère l'email de l'utilisateur depuis Firestore
  Future<void> getUserData() async {
    final docRef =
    FirebaseFirestore.instance.collection("users").doc(widget.userID);
    final doc = await docRef.get();
    if (doc.exists) {
      setState(() {
        _mailUser = doc.data()?["email"] ?? "Inconnu";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClair,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 120,
        backgroundColor: vertMoyen,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 15),
            const Text("Classement", style: TextStyle(fontSize: 16, color: Colors.white)),
            Expanded(
              child: Center(
                child: Image.asset('assets/images/logoSansFond.png', height: 80),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => profile(userID: widget.userID),
                      ),
                    );
                  },
                  icon: Icon(Icons.account_circle_sharp, color: Colors.white, size: 25),
                  label: Text(_mailUser, style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(100, 10, 100, 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('joueurs')
                    .orderBy('Partie', descending: true)
                    .where('Partie',isEqualTo: _partie.getPartieID())
                    .orderBy('Temps', descending: false) // Trie par Temps croissant
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    print(snapshot);
                    print(_partie.getPartieID());
                    return const Center(child: CircularProgressIndicator());
                  }

                  print(snapshot);
                  var joueurs = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Point de passage manquant', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Temps', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: joueurs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return DataRow(cells: [
                          DataCell(Text(data['Nom'] ?? 'Inconnu')),
                          DataCell(Text(data['Point de passage manquant']?.toString() ?? '0')),
                          DataCell(Text(data['Temps'] ?? '00:00:00')),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
          // Bouton Accueil correctement placé en bas de la page
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  _partie.setEstLancee(false);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: vertFonce, // Couleur du texte
                  minimumSize: const Size(150, 50), // Taille du bouton
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding du texte
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Stopper la partie'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AccueilWeb(userID: _userID)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: vertFonce, // Couleur du texte
                  minimumSize: const Size(150, 50), // Taille du bouton
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding du texte
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Accueil'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
