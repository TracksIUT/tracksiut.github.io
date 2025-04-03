import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Définir la classe Joueur avec le chrono et les autres informations
class Joueur {
  String nom;
  String idPartie;
  int nbrPointPassageRestant;
  String chrono; // Ajout du chrono

  Joueur({
    required this.nom,
    required this.idPartie,
    required this.nbrPointPassageRestant,
    required this.chrono, // Ajouter le chrono
  });

  // Sauvegarder le joueur dans Firestore
  Future<void> saveToFirestore() async {
      await FirebaseFirestore.instance.collection('joueurs').doc().set({
      'Nom': nom,
      'Partie': idPartie,
      'Point de passage manquant': nbrPointPassageRestant,
      'Temps': chrono, // Ajouter le chrono à la Map
    });

  }
}

class PJoueur extends StatefulWidget {
  final Joueur joueur; // Joueur à sauvegarder

  const PJoueur({Key? key, required this.joueur}) : super(key: key);

  @override
  _JoueurState createState() => _JoueurState();
}

class _JoueurState extends State<PJoueur> {
  @override
  void initState() {
    super.initState();
    _saveJoueur(); // Sauvegarde le joueur dès l'affichage de la page
  }

  // Enregistrer le joueur dans Firestore dès l'affichage de la page
  Future<void> _saveJoueur() async {
    await widget.joueur.saveToFirestore();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Joueur ${widget.joueur.nom} enregistré !")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Joueur Enregistré")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Nom: ${widget.joueur.nom}", style: TextStyle(fontSize: 18)),
            Text("Partie: ${widget.joueur.idPartie}", style: TextStyle(fontSize: 18)),
            Text("Points Manquant: ${widget.joueur.nbrPointPassageRestant}", style: TextStyle(fontSize: 18)),
            Text("Chrono: ${widget.joueur.chrono}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Retour à la page précédente
              },
              child: Text("Retour"),
            ),
          ],
        ),
      ),
    );
  }
}
