import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:tracks/back/enigme.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:diacritic/diacritic.dart';


/// Classe EnigmeImage
///
/// Représente une énigme basée sur une image, avec un intitulé, une réponse attendue
/// et une image associée. Cette classe hérite de la classe [Enigme].
class EnigmeImage extends Enigme {
  String? _reponseAttendue; // La réponse attendue pour résoudre l'énigme.
  String? _intituleEnigme; // L'intitulé ou la description de l'énigme.
  String? _image; // Chemin ou URL de l'image associée à l'énigme.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Constructeur principal.
  ///
  /// Crée une instance de `EnigmeImage`.
  ///
  /// - [nomEnigme] : Le nom de l'énigme.
  /// - [reponseAttendue] : La réponse attendue pour résoudre l'énigme.
  /// - [intituleEnigme] : La description ou l'intitulé de l'énigme.
  /// - [image] : Le chemin ou l'URL de l'image associée.
  EnigmeImage( String typeEnigme, String enigmeID,
      {String? reponseAttendue, String? intituleEnigme, String? image})
      : _reponseAttendue = reponseAttendue,
        _intituleEnigme = intituleEnigme,
        _image = image,
        super(enigmeID){
    constructeurSetEnigme(enigmeID);
    setType(typeEnigme);
    print("[+] EnigmeImage");
  }

  /// Constructeur nommé pour créer une énigme image et l'enregistrer dans Firestore.
  ///
  /// - [nomEnigme] : Le nom de l'énigme.
  /// - [intituleEnigme] : La description ou l'intitulé de l'énigme.
  /// - [reponseAttendue] : La réponse attendue pour résoudre l'énigme.
  /// - [image] : Le chemin ou l'URL de l'image associée
  EnigmeImage.createEnigmeImage(
      String nomEnigme,
      String intituleEnigme,
      String reponseAttendue,
      String image,
      ) : super.createEnigme(false, "EnigmeImage") {
    _intituleEnigme = intituleEnigme;
    _reponseAttendue = reponseAttendue;
    _image = image;

    final data = <String, dynamic>{
      'intituleEnigme': _intituleEnigme,
      'reponseAttendue': _reponseAttendue,
      'image': _image,
    };

    _firestore.collection("EnigmeImage").doc(getEnigmeID()).set(data);
    print("[+] EnigmeImage.createEnigmeImage : $data");
  }

  /// Met à jour les propriétés de l'instance avec les données de Firestore.
  ///
  /// Charge les données correspondant à l'identifiant de l'énigme depuis Firestore
  /// et met à jour les attributs de l'instance en conséquence.
  Future<void> mettreAJourInstance() async {
    try {
      final doc = await _firestore.collection("EnigmeImage").doc(getEnigmeID()).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Mise à jour des propriétés spécifiques à EnigmeImage
        _intituleEnigme = data["intituleEnigme"];
        _reponseAttendue = data["reponseAttendue"];
        _image = data["image"];

        super.mettreAJourInstance();

        print("Mise à jour réussie depuis Firestore.");
      } else {
        print("Document inexistant pour ID: ${getEnigmeID()}");
      }
    } catch (e) {
      print("Erreur lors de la récupération des données Firestore : $e");
    }
  }



  /// Met à jour les données dans Firestore à partir de l'instance.
  ///
  /// Cette méthode synchronise les modifications locales des attributs de l'énigme
  /// avec la base de données Firestore.
  Future<void> mettreAJourBD() async {
    // Mise à jour des données spécifiques à EnigmeImage
    final data = <String, dynamic>{
      'intituleEnigme': _intituleEnigme,
      'reponseAttendue': _reponseAttendue,
      'image': _image,
    };

    // Appeler la méthode de mise à jour de la classe parente pour mettre à jour d'autres champs
    super.mettreAJourBD();

    // Mettre à jour les données de EnigmeImage dans Firestore
    _firestore.collection("EnigmeImage").doc(getEnigmeID()).update(data).then(
          (_) => print("EnigmeImage mise à jour avec succès"),
      onError: (e) => print("Erreur de mise à jour: $e"),
    );
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



  /// Convertit l'instance en chaîne de caractères pour le débogage.
  ///
  /// Retourne une chaîne décrivant les attributs de l'énigme image.
  @override
  String toString() {
    return '${super.toString()} EnigmeImage { '
        'intituleEnigme: $_intituleEnigme, '
        'reponseAttendue: $_reponseAttendue, '
        'image: $_image, '
        '}';
  }

  /// Retourne l'intitulé de l'énigme.
  String? getIntituleEnigme() {
    return _intituleEnigme;
  }

  /// Retourne l'URL ou chemin de l'image associée.
  String? getElementSpecial() {
    return _image;
  }

  String? getReponseAttendue(){
    return _reponseAttendue;
  }

  Future<void>constructeurSetEnigme(String id)async{
    final nom = await FirebaseFirestore.instance.collection("Enigme").doc(id).get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data;
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }


  /// Met à jour l'intitulé de l'énigme et synchronise avec Firestore.
  ///
  /// - [intituleEnigme] : Le nouvel intitulé de l'énigme.
  void setIntituleEnigme(String intituleEnigme) {
    _intituleEnigme = intituleEnigme;
    _firestore.collection("EnigmeImage").doc(getEnigmeID()).update({'intituleEnigme': _intituleEnigme});
  }

  /// Met à jour la réponse attendue et synchronise avec Firestore.
  ///
  /// - [reponseAttendue] : La nouvelle réponse attendue pour l'énigme.
  void setReponseAttendue(String reponseAttendue) {
    _reponseAttendue = reponseAttendue;
    _firestore.collection("EnigmeImage").doc(getEnigmeID()).update({'reponseAttendue': _reponseAttendue});
  }

  /// Met à jour l'image associée et synchronise avec Firestore.
  ///
  /// - [image] : Le nouveau chemin ou l'URL de l'image.
  void setImage(String image) {
    _image = image;
    _firestore.collection("EnigmeImage").doc(getEnigmeID()).update({'image': _image});
  }

  /// Met à jour tous les champs de l'énigme (hérités et spécifiques) et synchronise avec Firestore.
  ///
  /// - [nom] : Le nouveau nom de l'énigme.
  /// - [intituleEnigme] : Le nouvel intitulé de l'énigme.
  /// - [reponseAttendue] : La nouvelle réponse attendue.
  /// - [image] : Le nouveau chemin ou l'URL de l'image.
  /// - [validee] : Le nouvel état de validation de l'énigme.
  void setEnigmeImage(String nom, String intituleEnigme, String reponseAttendue, String image, bool validee) {
    // Appeler la méthode de la classe parente pour mettre à jour les champs hérités
    super.setEnigme(validee);

    // Mise à jour des champs spécifiques à EnigmeImage
    _intituleEnigme = intituleEnigme;
    _reponseAttendue = reponseAttendue;
    _image = image;

    // Synchronisation avec Firestore pour les champs spécifiques
    _firestore.collection("EnigmeImage").doc(getEnigmeID()).update({
      'intituleEnigme': _intituleEnigme,
      'reponseAttendue': _reponseAttendue,
      'image': _image,
    }).then(
          (_) {
        print("Les données spécifiques de l'énigme image ont été mises à jour avec succès.");
      },
      onError: (error) {
        print("Erreur lors de la mise à jour des données spécifiques de l'énigme image: $error");
      },
    );
  }

@override
  factory EnigmeImage.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options){
    final data = snapshot.data();
    FirebaseFirestore.instance
        .collection("Enigme")
        .doc()
        .withConverter(
      fromFirestore: EnigmeImage.fromFirestore,
      toFirestore: (EnigmeImage enigme, _) =>
          enigme.toFirestore(),
    ).get();
    return EnigmeImage(
      "EnigmeImage",
      snapshot.id,
      reponseAttendue: data?['reponseAttendue'],
      intituleEnigme: data?['intituleEnigme'],
      image: data?['image'],
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      if (_reponseAttendue != null) 'reponseAttendue': _reponseAttendue,
      if (_intituleEnigme != null) 'intituleEnigme': _intituleEnigme,
      if (_image != null) 'image': _image,
    };
  }

  @override
  String? getNomEnigme() {
    // TODO: implement getNomEnigme
    throw UnimplementedError();
  }

  @override
  Widget affiche() {
    // TODO: implement affiche
    throw UnimplementedError();
  }
}
