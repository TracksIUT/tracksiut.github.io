import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:tracks/back/enigme.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';

/// Classe EnigmeText
///
/// Représente une énigme textuelle, avec un intitulé et une réponse attendue.
/// Hérite de la classe [Enigme].
///
class EnigmeText extends Enigme {
  String? _reponseAttendue; // Réponse correcte de l'énigme
  String? _intituleEnigme; // Question ou description de l'énigme
  String? _nomEnigme; // Nom de l'énigme
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Constructeur principal
  ///
  /// [nomEnigme] Nom de l'énigme.
  /// [reponseAttendue] Réponse attendue pour résoudre l'énigme.
  /// [intituleEnigme] Description ou intitulé de l'énigme.
  EnigmeText(String id,String nomEnigme,
      {String? reponseAttendue, String? intituleEnigme})
      : _reponseAttendue = reponseAttendue,
        _intituleEnigme = intituleEnigme,
        _nomEnigme = nomEnigme,
        super(id){
    print("[+] EnigmeText");
  }

  /// Constructeur nommé pour créer une énigme textuelle avec stockage dans Firebase
  ///
  /// [nomEnigme] Nom de l'énigme.
  /// [intituleEnigme] Description ou intitulé de l'énigme.
  /// [reponseAttendue] Réponse attendue pour résoudre l'énigme.
  EnigmeText.createEnigmeText(String nomEnigme, String intituleEnigme, String reponseAttendue)
      : super.createEnigme(false, "EnigmeText") {
    _nomEnigme = nomEnigme;
    _intituleEnigme = intituleEnigme;
    _reponseAttendue = reponseAttendue;

    //création de l'instance dans firebase et enregistrement des informations données
    final data = <String, dynamic>{
      'nomEnigme' : _nomEnigme,
      'intituleEnigme': _intituleEnigme,
      'reponseAttendue': _reponseAttendue,
    };

    _firestore.collection("EnigmeText").doc(super.getEnigmeID()).set(data);

    print("[+] EnigmeText.createEnigmeText");
  }

  /// Met à jour l'instance avec les données récupérées depuis Firestore.
  Future<void> mettreAJourInstance() async {
    _firestore.collection("EnigmeText").doc(getEnigmeID()).get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        _nomEnigme = data["nomEnigme"];
        _intituleEnigme = data["intituleEnigme"];
        _reponseAttendue = data["reponseAttendue"];
      },
      onError: (e) => print("Erreur lors de la récupération du document : $e"),
    );
  }

  /// Met à jour les données dans Firebase à partir de l'instance.
  Future<void> mettreAJourBD() async {
    final data = <String, dynamic>{
      "nomEnigme": _nomEnigme,
      'intituleEnigme': _intituleEnigme,
      'reponseAttendue': _reponseAttendue,
    };
    _firestore.collection("EnigmeText").doc(getEnigmeID()).update(data).then(
          (_) => print("EnigmeText mise à jour avec succès"),
      onError: (e) => print("Erreur de mise à jour: $e"),
    );
  }

  /// Retourne l'intitulé de l'énigme.
  String? getIntituleEnigme() {
    return _intituleEnigme;
  }

  String? getReponseAttendue(){
    return _reponseAttendue;
  }

  String? getNomEnigme(){
    return _nomEnigme;
  }

  String? getElementSpecial(){
    return _intituleEnigme;
  }

  void setNomEnigme(String newValue){
    _nomEnigme = newValue;
    /*_firestore.collection("EnigmeText").doc(getEnigmeID()).update({'nomEnigme': _nomEnigme});*/
  }

  /// Met à jour l'intitulé de l'énigme et synchronise avec Firestore.
  void setIntituleEnigme(String intituleEnigme) {
    _intituleEnigme = intituleEnigme;
    /*_firestore.collection("EnigmeText").doc(getEnigmeID()).update({'intituleEnigme': _intituleEnigme});*/
  }

  /// Met à jour la réponse attendue et synchronise avec Firestore.
  void setReponseAttendue(String reponseAttendue) {
    _reponseAttendue = reponseAttendue;
    /*_firestore.collection("EnigmeText").doc(getEnigmeID()).update({'reponseAttendue': _reponseAttendue});*/
  }

  /// Met à jour tous les champs de l'énigme et synchronise avec Firestore.
  ///
  /// §§§§ Obsolète ???? §§§§§§§
  void setEnigmeText(String nom, String intituleEnigme, String reponseAttendue) {
    _intituleEnigme = intituleEnigme;
    _reponseAttendue = reponseAttendue;
    mettreAJourBD();  // Met à jour dans la base de données
  }

  /// Constructeur pour récupérer une énigme textuelle depuis Firestore.
  factory EnigmeText.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return EnigmeText(
      snapshot.id,
      data?['nomEnigme'],
      reponseAttendue: data?['reponseAttendue'],
      intituleEnigme: data?['intituleEnigme'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (_nomEnigme != null) 'nomEnigme': _nomEnigme,
      if (_reponseAttendue != null) 'reponseAttendue': _reponseAttendue,
      if (_intituleEnigme != null) 'intituleEnigme': _intituleEnigme,
    };
  }

  /// Vérifie si la réponse donnée correspond à la réponse attendue en tenant compte de tolérances.
  ///
  /// Cette méthode compare la réponse fournie par l'utilisateur à la réponse attendue
  /// en ignorant la casse, en supprimant les accents et en tolérant de légères erreurs
  /// d'orthographe grâce à l'utilisation de la distance de Levenshtein.
  ///
  /// [reponse] La réponse fournie par l'utilisateur. Elle sera comparée à la réponse
  /// attendue avec des règles de tolérance.
  ///
  /// Retourne [true] si la réponse est correcte ou suffisamment proche (tolérance d'erreurs),
  /// sinon retourne [false]. L'état de l'énigme est mis à jour à true si la réponse est correcte.
  @override
  bool verificationReponse(String reponse) {
    if (_reponseAttendue == null) {
      throw StateError("La réponse attendue est indéfinie.");
    }

    // Normaliser les chaînes pour ignorer la casse et les accents
    String reponseNormalisee = removeDiacritics(reponse.toLowerCase());
    String reponseAttendueNormalisee = removeDiacritics(_reponseAttendue!.toLowerCase());

    // Calculer la distance de Levenshtein
    final Levenshtein levenshtein = Levenshtein();
    int distance = levenshtein.distance(reponseNormalisee, reponseAttendueNormalisee);

    // Définir une tolérance (10 % de la longueur de la réponse attendue)
    int tolerance = (reponseAttendueNormalisee.length * 0.10).ceil();

    if (distance <= tolerance) {
      setValidee(true); // Mise à jour de l'état de l'énigme
      return true;
    }

    return false;
  }

  ///Supprime l'énigme de la base de données
  @override
  Future<void> supprimerEnigme() async{
    print("supprimerEnigme() : enigmeText");
    FirebaseFirestore.instance.collection("Enigmetext").doc(super.getEnigmeID()).delete().then(
          (doc) => print("Document deleted"),
      onError: (e) => print("Error updating document $e"),
    );
    super.supprimerEnigme();
  }



  /// Convertit l'instance en chaîne de caractères pour le débogage.
  @override
  String toString() {
    return '${super.toString()} EnigmeText { '
        'intituleEnigme: $_intituleEnigme, '
        'reponseAttendue: $_reponseAttendue, '
        'nomEnigme: $_nomEnigme, '
        '}';
  }

  Widget affiche() {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.0, left: 10, right: 10),
      child: Card(
        color: Color(0xFF4b8c72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Informations sur l'enigme
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nom : ",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _nomEnigme.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // intitule
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question : ",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _intituleEnigme.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Réponse attendue : ",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _reponseAttendue.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
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
}
