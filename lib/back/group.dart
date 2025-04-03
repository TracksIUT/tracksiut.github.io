import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracks/back/circuit.dart';



class Group {
  String? _groupID;
  String? _nom;
  String? _codeGroup;
  String? _circuitID;
  String? _partieID;
  Circuit? _circuit;

  Group(String groupID,String nom, String codeGroup, String circuitID, String partieID){
    _groupID=groupID;
    _codeGroup=codeGroup;
    _circuitID=circuitID;
    _partieID=partieID;
  }

  ///Constructeur d'un nouveau groupe
  ///
  /// [circuitID] l'id du circuit contenu par la partie
  /// [partieID] l'id de la partie a laquel appartient le groupe
  Group.createGroup(String circuitID, String partieID){
    _groupID = FirebaseFirestore.instance.collection('groupe').doc().id;
    _codeGroup = "Test";
    _circuitID = circuitID;
    _partieID = partieID;

    final data = <String, dynamic>{
      'nom' : _nom,
      'codeGroup': _codeGroup,
      'circuit': _circuitID,
      'partie':_partieID,
    };
    FirebaseFirestore.instance.collection("groupe").doc(_groupID).set(data);
  }

  Future<void> recupererCircuit() async{
    final ref = FirebaseFirestore.instance
        .collection("circuit")
        .doc(_circuitID)
        .withConverter(
      fromFirestore: Circuit.fromFirestore,
      toFirestore: (Circuit circuit, _) => circuit.toFirestore(),
    );
    final docSnap = await ref.get();
    _circuit = docSnap.data();
  }

  Future<void> supprimerGroup()async{
    FirebaseFirestore.instance.collection("group").doc(_groupID).delete().then(
          (doc) => print("Document deleted"),
      onError: (e) => print("Error updating document $e"),
    );
  }

  void setCodeGroup(String newCode){
    _codeGroup=newCode;
  }

  void setGroup(String nom){
    _nom=nom;
  }

  String? getCodeGroup(){
    return _codeGroup;
  }

  String? getNom(){
    return _nom;
  }

  void mettreAJourBD(){
    final data = <String, dynamic>{
      'nom' : _nom,
      'codeGroup': _codeGroup,
      'circuit': _circuitID,
      'partie':_partieID,
    };
    FirebaseFirestore.instance.collection("groupe").doc(_groupID).update(data);
  }

  void mettreAJourInstance(){
    FirebaseFirestore.instance.collection("groupe").doc(_groupID).get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        _nom = data["nom"];
        _codeGroup = data['codeGroup'];
        _circuitID = data['circuit'];
        _partieID = data['partie'];
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }


  ///Le constructeur qui permet de récupérer un circuit depuis la base de donnée
  ///
  factory Group.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Group(
      snapshot.id,
      data?['nom'],
      data?['codeGroup'],
      data?['circuit'],
      data?['partie'],
    );
  }

  ///Lié à Circuit.fromFirestore()
  Map<String, dynamic> toFirestore() {
    return {
      if (_nom != null) "nom": _nom,
      if (_codeGroup != null) "codeGroup": _codeGroup,
      if (_circuitID != null) "circuit": _circuitID,
      if (_partieID != null) "partie": _partieID,
    };
  }
}