import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Enigme {
  String? _enigmeID; // ID unique généré par Firestore pour chaque énigme
  bool _validee = false; // Status de validation
  String? _type="";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Enigme(String id){
    _enigmeID = id;
  }
  String? getElementSpecial();
  String? getReponseAttendue();
  String? getIntituleEnigme();
  String? getNomEnigme();
  Widget affiche();

  // Retourne l'ID de l'énigme
  String? getEnigmeID() {
    return _enigmeID;
  }

  // Setter pour valider ou invalider l'énigme
  void setValidee(bool validee) {
    _validee = validee;
    _firestore.collection("Enigme").doc(getEnigmeID()).update({'validee': validee});
  }

  /// Met à jour les champs et synchronise avec Firestore.
  ///
  /// - [nom] : Le nouveau nom de l'énigme.
  /// - [validee] : Le nouvel état de validation de l'énigme.
  void setEnigme(bool validee) {
    setValidee(validee);

    _firestore.collection("Enigme").doc(getEnigmeID()).update({
      'validee': validee,
    }).then(
          (_) {
        print("Les données de base de l'énigme ont été mises à jour avec succès.");
      },
      onError: (error) {
        print("Erreur lors de la mise à jour des données de base de l'énigme: $error");
      },
    );
  }



  String? getType(){
    return _type;
  }
  void setType(String type){
    _type=type;
  }

  // Vérifie si l'énigme est validée
  bool isValidee() {
    return _validee;
  }

  // Méthode pour la vérification de la réponse - à implémenter dans les sous-classes
  bool verificationReponse(String reponse);

  /// Constructeur nommé pour créer une énigme image avec un enregistrement dans Firestore.
  Enigme.createEnigme(bool validee, String type) {
    _enigmeID = _firestore.collection("Enigme").doc().id;
    _validee = validee;

    final data = <String, dynamic>{
      'validee': _validee,
      'type': type,
    };

    _firestore.collection("Enigme").doc(_enigmeID).set(data);
    print("[+] Enigme.createEnigme");
  }

  Future<void> supprimerEnigme() async{
    print("supprimerEnigme() : enigme");
    FirebaseFirestore.instance.collection("Enigme").doc(_enigmeID).delete().then(
          (doc) => print("Document deleted"),
      onError: (e) => print("Error updating document $e"),
    );
  }

  Future<void> mettreAJourInstance() async {
    try {
      final doc = await _firestore.collection("Enigme").doc(_enigmeID).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Mise à jour des propriétés spécifiques à EnigmeImage
        _validee = data["validee"];

        print("Mise à jour réussie depuis Firestore.");
      } else {
        print("Document inexistant pour ID: ${_enigmeID}");
      }
    } catch (e) {
      print("Erreur lors de la récupération des données Firestore : $e");
    }
  }

  // Méthode pour mettre à jour la base de données depuis la classe parente
  Future<void> mettreAJourBD() async {
    final data = <String, dynamic>{
      'validee': _validee,
    };

    FirebaseFirestore.instance.collection("Enigme").doc(_enigmeID).update(data).then(
          (_) => print("Enigme mise à jour avec succès"),
      onError: (e) => print("Erreur de mise à jour: $e"),
    );
  }

  @override
  String toString() {
    return 'Enigme { '
        'enigmeID: $_enigmeID, '
        'validee: $_validee '
        '}';
  }

}
