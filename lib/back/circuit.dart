import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracks/back/pointpassage.dart';

////Les ID des circuits créés devrons êtres stockés dans une liste d'iD circuit dans le compte organisateur
///La classe Circuit
///
/// [_circuitID] ID du circuit, généré automatiquement à la création du circuit
/// [_nom] Nom du circuit
/// [_description] Description du circuit
/// [_lstPointPassage] Liste des points de passages composants le circuit
class Circuit {
  String? _nom;
  String? _description;
  String? _circuitID;
  List<dynamic>? _lstPointPassage = [];
  bool _ordrePointPassage = false;

  ///Constructeur interne
  ///
  /// [nom] le nom du circuit
  /// [description] la description du circuit
  /// [circuitID] l'id du circuit
  /// [lstPointPassage] la liste des points de passages du circuit
  /// Ce constructeur n'enregistre rien dans la base de donnée.
  Circuit(String nom, String description, String circuitID, lstPointPassage, {bool ordrePointPassage = false}) {
    _nom = nom;
    _description = description;
    _circuitID = circuitID;
    _lstPointPassage = lstPointPassage;
    _ordrePointPassage = ordrePointPassage;
    print("[+] Circuit");
  }

  ///Creation d'un circuit
  ///
  /// [nom] le nom du circuit
  /// [description] la description du circuit
  /// Creation du circuit dans la base de donnée
  Circuit.createCircuit(String nom, String description) {
    _circuitID = FirebaseFirestore.instance.collection('circuit').doc().id;
    _nom = nom;
    _description = description;
    _ordrePointPassage = false;

    //création de l'instance dans firebase et enregistrement des informations données
    final data = <String, dynamic>{
      'nom': _nom,
      'description': _description,
      'lstPointPassage': _lstPointPassage,
      'ordrePointPassage':  _ordrePointPassage,
    };
    FirebaseFirestore.instance.collection("circuit").doc(_circuitID).set(data);

    print("[+] Circuit.createCircuit");
  }


  //Cette fonction est encore a tester
  /// Copie d'un circuit
  ///
  /// renvoie [nouveauCircuit] une copie du circuit courant avec un nouvel identifiant
  /// [lstPointPassage] la liste des points de passages qui sont succeptibles d'êtres affectés par cette copie.
  /// [lstEnigmes] la liste des points de passages qui sont succeptibles d'êtres affectés par cette copie.
  Future<Circuit> copieCircuit(List<String> lstPointPassage, List<String> lstEnigmes) async {
    Circuit nouveauCircuit = new Circuit.createCircuit(_nom as String, _description as String);

    //appeler constructeur par copie des points de passages
    PointPassage? pointPassage;
    for (int i =0; i<_lstPointPassage!.length; i++){
      pointPassage= await recupererPointPassageBD(_lstPointPassage![i]);
      //A FAIRE recuperer une liste d'énigmes avec des nouvelles ID ( "copie/ dupliquer") -> ceci est pour que les énigmes soient modifiables après avoir été copiées
      //Le même contenu d'énigmes mais avec de nouveaux identifiants et dupliquées dans la base de donnée
      String enigmesID = pointPassage!.getEnigme()!;
      //
      pointPassage = pointPassage.copiePointPassage(enigmesID); //pour acter l'enregistrement d'un nouveau point de passage dans la base de donnée
      nouveauCircuit.ajouterPointPassage(pointPassage.getID());
    }
    return nouveauCircuit;

  }



  ///Suppression du circuit de la base de donnée
  ///
  ///Attention, cette fonction ne supprime pas l'instance
  Future<void> supprimerCircuit() async {
    for (int i=0; i<_lstPointPassage!.length; i++){
      supprimerPointPassage(_lstPointPassage![i]);
    }
    FirebaseFirestore.instance.collection("circuit").doc(_circuitID).delete().then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );
  }



  //la mise a jour de l'instance ne se passe pas correctement ?
  ///supprime le lien du circuit vers le point de passage
  ///
  /// [pointPassageID] l'ID du point de passage à supprimer de la liste
  Future<void> supprimerPointPassage(String? pointPassageID) async {
    if (_lstPointPassage!.contains(pointPassageID)) {
      _lstPointPassage!.remove(pointPassageID);

      final updates = <String, dynamic>{
        "lstPointPassage": _lstPointPassage,
      };
      FirebaseFirestore.instance.collection("circuit").doc(_circuitID).update(
          updates);
    }
    PointPassage? pointPassageASupprimer = await recupererPointPassageBD(pointPassageID!);
    pointPassageASupprimer!.supprimerPointPassage();

  }
  void supprimerPointPassageSansModifBD(String pointPassageID){
    if (_lstPointPassage!.contains(pointPassageID)) {
      _lstPointPassage!.remove(pointPassageID);
    }
  }

  String? getNom(){
    return _nom;
  }

  String? getDescription(){
    return _description;
  }

  String? getID(){
    return _circuitID;
  }

  List<dynamic>? getLstPointPassage(){
    return _lstPointPassage;
  }

  bool getOrdrePointPassage(){
    return _ordrePointPassage;
  }

  bool get ordrePointPassage => _ordrePointPassage;

  void setNom(String nom){
    _nom=nom;
    FirebaseFirestore.instance.collection("circuit").doc(_circuitID).update(<String, dynamic>{'nom' : _nom});
  }

  void setDescription(String description){
    _description=description;
    FirebaseFirestore.instance.collection("circuit").doc(_circuitID).update(<String, dynamic>{'description' : _description});
  }

  void setOrdrePointPassage(bool ordre){
    _ordrePointPassage = ordre;
    FirebaseFirestore.instance.collection("circuit").doc(_circuitID).update(<String, dynamic>{'ordrePointPassage' : _ordrePointPassage});
  }

  void setCircuit(String nom,String description,List<dynamic> lst, bool ordre){
    _nom=nom;
    _description=description;
    _lstPointPassage=lst;
    _ordrePointPassage=ordre;
    mettreAJourBD();
  }

  void ajoutPointPassage(String pointPassageID){
    _lstPointPassage!.add(pointPassageID);
    mettreAJourBD();
  }


  ///Met a jour l'instance avec les données de la base de donnée
  Future<void> mettreAJourInstance() async{
    FirebaseFirestore.instance.collection("circuit").doc(_circuitID).get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        _nom = data["nom"];
        _description = data['description'];
        _lstPointPassage = data['lstPointPassage'] is Iterable
            ? List.from(data['lstPointPassage'])
            : null;
        _ordrePointPassage = data['ordrePointPassage'];
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  ///Met a jour la base de donnée avec les données de l'instance
  Future<void> mettreAJourBD() async {
    final data = <String, dynamic>{
      'nom': _nom,
      'description': _description,
      'lstPointPassage': _lstPointPassage,
      'ordrePointPassage': _ordrePointPassage,
    };
    FirebaseFirestore.instance.collection("circuit").doc(_circuitID).update(data);
  }



  @override
  String toString() {
    String result = 'Circuit : ${_circuitID!}\nnom : ${_nom!}\ndescription : ${_description!}\nordrePointPassage : ${_ordrePointPassage}\nlstPointPassage :';
    if (_lstPointPassage!=null){
      for (int i= 0; i<_lstPointPassage!.length; i++){
        result = result + "\n[" + i.toString() +"]" + _lstPointPassage![i];
      }

    }
    return result;
  }


  //a revoir en fonction de l'utilisation
  //pour l'instant appèle la fonction de création, met à jour sur la base de donnée circuit
  //renvoie le point de passage créé
  ///Ajoute l'ID d'un point de passage a la liste des points de passages du circuit
  ///
  /// [pointPassageID] l'ID du point de passage a ajouter
  void ajouterPointPassage(String pointPassageID) {
    _lstPointPassage!.add(pointPassageID);
    final documentMisAJour = FirebaseFirestore.instance.collection("circuit").doc(_circuitID);
    final updates = <String, dynamic>{
      "lstPointPassage": _lstPointPassage,
    };
    documentMisAJour.update(updates);
  }


  //A déplacer ? -> dans une autre
  ///Renvoie une instance de PointPassage avec les données issues de la base de données
  ///
  /// [pointPassageID] l'ID du point de passage que l'on veut extraire de la base de donnée
  Future<PointPassage?> recupererPointPassageBD(String pointPassageID) async {
    final ref = FirebaseFirestore.instance.collection("pointPassage").doc(pointPassageID).withConverter(
      fromFirestore: PointPassage.fromFirestore,
      toFirestore: (PointPassage pointPassage, _) => pointPassage.toFirestore(),
    );
    final docSnap = await ref.get();
    final pointPassage = docSnap.data(); // Convert to City object
    return pointPassage;
  }



  ///Le constructeur qui permet de récupérer un circuit depuis la base de donnée
  ///
  /// Pour creer une instance de circuit depuis les données de la base de donnée :
  /// final ref = db.collection("circuit").doc(lstCircuit[0]).withConverter(
  ///       fromFirestore: Circuit.fromFirestore,
  ///       toFirestore: (Circuit circuit, _) => circuit.toFirestore(),
  ///     );
  ///     final docSnap = await ref.get();
  ///     final circuit1 = docSnap.data();
  factory Circuit.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Circuit(
      data?['nom'],
      data?['description'],
      snapshot.id,
      data?['lstPointPassage'] is Iterable
          ? List.from(data?['lstPointPassage'])
          : null,
      ordrePointPassage: data?['ordrePointPassage'] ?? false,
    );
  }

  ///Lié à Circuit.fromFirestore()
  Map<String, dynamic> toFirestore() {
    return {
      if (_nom != null) "nom": _nom,
      if (_description != null) "description": _description,
      if (_lstPointPassage != null) "lstPointPassage": _lstPointPassage,
      if (_ordrePointPassage != null) "ordrePointPassage": _ordrePointPassage,
    };
  }
}

