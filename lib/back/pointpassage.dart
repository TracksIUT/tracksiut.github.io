import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracks/back/circuit.dart';
import 'package:tracks/back/enigme.dart';
import 'package:tracks/back/enigmeImage.dart';
import 'package:tracks/back/enigmeText.dart';

///La classe PointPassage
///
/// [_pointPassageID] ID du point de passage, généré automatiquement à la création du point de passage
/// [_nom] Nom du point de passage
/// [_descriptionEndroit] Description du point de passage;
/// [_arrivee] booléen, si vrai : ce point de passage est un point d'arrivée
/// [_depart] booléen, si vrai : ce point de passage est un point de départ
/// [_Enigmes] ID  de l'énigme liée au point de passage
/// [_lstPointPassagePrecedent] Liste d'ID des points de passages a valider pour débloquer celui-ci
/// [_lstPointPassageSuivant] Liste d'ID dont le point de passage est le précédent
class PointPassage {
  bool? _arrivee;
  bool? _depart;
  String? _nom;
  String? _descriptionEndroit;
  String? _pointPassageID;
  String? _Enigmes;
  List<String>? _lstPointPassagePrecedent; //a voir plus tard comment modifier, suprimer etc..
  List<String>? _lstPointPassageSuivant; //a voir plus tard comment modifier, suprimer etc..
  final FirebaseFirestore _baseDonnePP = FirebaseFirestore.instance;

  ///Constructeur interne
  ///
  /// [nom] le nom du point de passage
  /// [descriptionEndroit] une description du point de passage
  /// [pointPassageID] l'ID du point de passage
  /// Ce constructeur n'enregistre rien dans la base de donnée.
  PointPassage(String nom, String descriptionEndroit, String pointPassageID,
      String? Enigmes, List<String>? lstPointPassageSuivant, List<String>? lstpointPassagePrecedent, bool arrivee , bool depart ) {
    _nom = nom;
    _descriptionEndroit = descriptionEndroit;
    _pointPassageID = pointPassageID;
    _Enigmes = Enigmes;
    _lstPointPassageSuivant = lstPointPassageSuivant;
    _arrivee=arrivee;
    _depart =depart;
    _lstPointPassagePrecedent=lstpointPassagePrecedent;
  }


  //le constructeur de base a utiliser lors de la création d'un circuit
  ///Creation d'un circuit
  ///
  /// [nom] le nom du point de passage
  /// [description] la description du point de passage
  /// Creation du point de passage dans la base de donnée.
  PointPassage.createPointPassage(String nom, String description) {
    _pointPassageID = _baseDonnePP.collection('pointPassage').doc().id;
    _nom = nom;
    _descriptionEndroit = description;
    _Enigmes="";
    _depart=false;
    _arrivee=false;
    _lstPointPassageSuivant=[];
    _lstPointPassagePrecedent=[];


    //création de l'instance dans firebase et enregistrement des informations données
    final data = <String, dynamic>{
      'nom': _nom,
      'descriptionEndroit': _descriptionEndroit,
      'arrivee': _arrivee,
      'depart' : _depart,
      'Enigmes': _Enigmes,
      'lstpointPassagePrecedent': _lstPointPassagePrecedent,
      'lstPointPassageSuivant' : _lstPointPassageSuivant,
    };
    _baseDonnePP.collection("pointPassage").doc(_pointPassageID).set(data);
  }

  // A revoir, ne pas oublier de modifier la documentation aussi
  ///Renvoie une copie du point de passage courant
  ///
  /// [lstEnigmesID] la liste des ID des Enigmes qui sont lié au nouveau point de passage (les Id des Enigmes dupliquées ?)
  /// Enregistre dans la base de donnée un nouveau point de passage avec une nouvelle ID mais avec les mêmes caractéristiques
  PointPassage copiePointPassage(String EnigmesID){
    PointPassage nouveauPointPassage = PointPassage(_nom as String , _descriptionEndroit as String, _pointPassageID as String, EnigmesID, _lstPointPassageSuivant, _lstPointPassagePrecedent, _arrivee as bool, _depart as bool);
    return nouveauPointPassage;
  }

  ///Met a jour l'instance avec les données de la base de donnée
  void mettreAJourInstance(){
    _baseDonnePP.collection("pointPassage").doc(_pointPassageID).get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        _nom = data["nom"];
        _descriptionEndroit = data['descriptionEndroit'];
        _arrivee = data['arrivee'];
        _depart = data['depart'];
        _Enigmes = data['Enigmes'];
        _lstPointPassagePrecedent = data['lstpointPassagePrecedent'] is Iterable
            ? List.from(data['lstpointPassagePrecedent'])
            : null;
        _lstPointPassageSuivant = data['lstPointPassageSuivant'] is Iterable
            ? List.from(data['lstPointPassageSuivant'])
            : null;
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  ///Met a jour la base de donnée avec les données de l'instance
  Future<void> mettreAJourBD() async{
    final data = <String, dynamic>{
      'nom': _nom,
      'descriptionEndroit': _descriptionEndroit,
      'arrivee': _arrivee,
      'depart' : _depart,
      'Enigmes': _Enigmes,
      'lstpointPassagePrecedent': _lstPointPassagePrecedent,
      'lstPointPassageSuivant' : _lstPointPassageSuivant,
    };
    await _baseDonnePP.collection("pointPassage").doc(_pointPassageID).update(data);
  }


  String getID(){
    return _pointPassageID!;
  }

  String? getNom(){
    return _nom;
  }

  String? getDescription(){
    return _descriptionEndroit;
  }

  String? getEnigme(){
    return _Enigmes;
  }

  List<String>? getLstPointPassagePrecedent(){
    return _lstPointPassagePrecedent;
  }

  List<String>? getLstPointPassageSuivant(){
    return _lstPointPassageSuivant;
  }

  bool getArrive(){
    return _arrivee!;
  }

  bool getDepart(){
    return _depart!;
  }



  // a appeller a chaque fois que l'utilisateur coche ou décoche la case (front)
  void changeArrive(){
    _arrivee = !_arrivee!;
  }

  void changeDepart(){
    _depart =!_depart!;
  }

  void setNom(String nom){
    _nom=nom;
  }

  void setDescription(String description){
    _descriptionEndroit=description;
  }

  void setEnigme(String enigmeID){
    _Enigmes = enigmeID;
  }

  void addPointPassagePrecedent(String pointPassageID){
    _lstPointPassagePrecedent!.add(pointPassageID);
  }

  void addPointPassageSuivant(String pointPassageID){
    _lstPointPassageSuivant!.add(pointPassageID);
  }


  ///Suppression du point de passage de la base de donnée
  ///
  /// [lstCircuitID] tous les circuit pouvant êtres affectés par cette suppression (la liste de tous les circuit de l'organisateur)
  Future<void> supprimerPointPassage() async {  //[List<String?>? lstCircuitID]
    //suppression du point de passage de la base de donnée
    _baseDonnePP
        .collection("pointPassage")
        .doc(_pointPassageID)
        .delete()
        .then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );
  }

  ///Validation d'un point de passage précédent
  ///
  /// [pointPassageID] le point de passage a supprimer de la liste
  /// Cette fonction est destinée à un usage par le joueur sur une instance.
  /// Elle ne modifie pas la base de donnée
  void validerPointPassagePrecedent(String pointPassageID){
    _lstPointPassagePrecedent!.remove(pointPassageID);
  }

  //a appeler lors du scan d'un point de passage/enigme pour savoir si on y a accès
  ///Validation de l'accès à un point de passage
  ///
  /// Cette fonction est à appeler lors du scan d'un point de passage.
  /// Elle sert a déterminer si le joueur a le droit d'y avoir accès.
  bool pointPassageValide(){
    if (_lstPointPassagePrecedent!=null){
      return false;
    }
    return true;
  }

/*
  bool? _arrivee;
  bool? _depart;
  String? _nom;
  String? _descriptionEndroit;
  String? _pointPassageID;
  List<String>? _lstEnigmes;
  List<String>? _lstPointPassagePrecedent; //a voir plus tard comment modifier, suprimer etc..
  List<String>? _lstPointPassageSuivant; //a voir plus tard comment modifier, suprimer etc..
  final FirebaseFirestore _baseDonnePP = FirebaseFirestore.instance;
  // A finir -----------------------------------------------------------------------------*/
  @override
  String toString() {
    String result = "Point de Passage : " +_pointPassageID! +'\nnom : ' +_nom! +'\ndescription : ' +_descriptionEndroit! +"\nlstEnigmes :"+"\narrive :" + _arrivee.toString()+"\ndepart :" + _depart.toString();
    if (_Enigmes != null) {
        result = result + _Enigmes!;
    }
    if (_lstPointPassagePrecedent != null) {
      for (int i = 0; i < _lstPointPassagePrecedent!.length; i++) {
        result = result + "[" + i.toString() + "]" + _lstPointPassagePrecedent![i];
      }
    }
    if (_lstPointPassageSuivant != null) {
      for (int i = 0; i < _lstPointPassageSuivant!.length; i++) {
        result = result + "[" + i.toString() + "]" + _lstPointPassageSuivant![i];
      }
    }
    return result;
  }

  //a revoir en fonction de l'utilisation
  //pour l'instant appèle la fonction de création, met à jour sur la base de donnée circuit
  //renvoie le point de passage créé
  /*Enigme creerEnigme() {
    Enigme enigme =new Enigme.createEnigme(acompleter);
    lstEnigme.add(enigme.enigmeID);
    baseDonne.collection("pointPassage").doc(_pointPassageID).update(<String, dynamic>{'lstEnigme' : lstEnigme});
    return enigme;
  }*/


  //appeler pour récupérer un circuit depuis la base de donnée
  ///Le constructeur qui permet de récupérer un circuit depuis la base de donnée
  ///
  /// Pour creer une instance de point de passage depuis les données de la base de donnée :
  /// final ref = _baseDonne.collection("pointPassage").doc(pointPassageID).withConverter(
  ///       fromFirestore: PointPassage.fromFirestore,
  ///       toFirestore: (PointPassage pointPassage, _) => pointPassage.toFirestore(),
  ///     );
  ///     final docSnap = await ref.get();
  ///     final pointPassage = docSnap.data(); // Convert to City object
  ///     return pointPassage;
  factory PointPassage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return PointPassage(
        data?['nom'],
        data?['descriptionEndroit'],
      snapshot.id,
      data?['Enigmes'],
      data?['lstPointPassageSuivant'] is Iterable ? List.from(data?['lstPointPassageSuivant']) : null,
      data?['lstpointPassagePrecedent'] is Iterable ? List.from(data?['lstpointPassagePrecedent']) : null,
      data?['arrivee'],
      data?['depart']
    );
  }

  ///Lié à PointPassage.fromFirestore()
  Map<String, dynamic> toFirestore() {
    return {
      if (_nom != null) "nom": _nom,
      if (_descriptionEndroit != null ) "descriptionEndroit": _descriptionEndroit,
      if (_Enigmes != null) "Enigmes": _Enigmes,
    };
  }
}
