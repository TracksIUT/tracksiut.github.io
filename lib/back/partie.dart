import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracks/back/circuit.dart';


///La classe Partie
///
/// [_nom] Nom de la Partie
/// [_partieID] ID de la Partie
/// [_circuitID] ID du circuit lié a la partie
/// [_lstGroupesID] la liste des ID des "comptes" des participants à la partie. Cette entité porte l'appelation "groupe"
class Partie {
  String? _nom;
  String? _partieID;
  String? _circuitID;
  String? _qrCode;
  bool _estLancee=false;


  ///Constructeur interne
  ///
  /// [_nom] Nom de la Partie
  /// [_partieID] ID de la Partie
  /// [_circuitID] ID du circuit lié a la partie
  /// [_lstGroupesID] la liste des ID des groupes
  /// [_qrCode] la chaine de caractère qui permet la génération et vérification du QRCode
  /// [_estLancee] permet de savoir si la partie est lancée
  /// Ce constructeur n'enregistre rien dans la base de donnée.
  Partie(String nom,String partieID,String circuitID, String? qrCode, bool lance){
    _nom=nom;
    _partieID=partieID;
    _circuitID=circuitID;
    _qrCode=qrCode;
    _estLancee=lance;
  }

  ///Creation d'une Partie
  ///
  /// [nom] Nom de la Partie
  /// [circuitID] Id du circuit lié à la partie
  /// Creation de la Partie dans la base de donnée
  Partie.createPartie(String nom, String circuitID){
    _partieID = FirebaseFirestore.instance.collection('partie').doc().id;
    _nom=nom;
    _circuitID=circuitID;
    _qrCode= "p"+_partieID!;
    _estLancee=false;

    final data = <String, dynamic>{
      'nom': _nom,
      'circuit': _circuitID,
      'qrcode' : _qrCode,
      'lancee' : _estLancee
    };
    FirebaseFirestore.instance.collection("partie").doc(_partieID).set(data);
  }

  Future <void> supprimerJoueurs() async{
    var collection = FirebaseFirestore.instance.collection('joueurs');
    var snapshot = await collection.where('Partie', isEqualTo: _partieID).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> supprimerPartie() async{
    print("Partie : supprimerPartie()");
    await supprimerJoueurs();
    if (_circuitID!.length!=0) {
      final ref = FirebaseFirestore.instance.collection("circuit").doc(
          _circuitID).withConverter(
        fromFirestore: Circuit.fromFirestore,
        toFirestore: (Circuit circuit, _) => circuit.toFirestore(),
      );
      final docSnap = await ref.get();
      Circuit? circuit = docSnap.data();
      circuit!.supprimerCircuit();
    }
    FirebaseFirestore.instance.collection("partie").doc(_partieID).delete().then(
          (doc) => print("Document deleted"),
      onError: (e) => print("Error updating document $e"),
    );
  }


  void genererQRCode(){
  //dans un fichier ?
  }

  String getNom(){
    return _nom!;
  }


  String getPartieID(){
    return _partieID!;
  }

  String? getCircuitID(){
    return _circuitID;
  }

  void setCircuitID(String circuitID){
    _circuitID = circuitID;
    FirebaseFirestore.instance.collection("partie").doc(_partieID).update(<String, dynamic>{'circuit' : _circuitID});
  }

 void setNom(String nom){
    _nom =nom;
    FirebaseFirestore.instance.collection("partie").doc(_partieID).update(<String, dynamic>{'nom' : _nom});
 }

 void setEstLancee(bool newEL){
    _estLancee=newEL;
    FirebaseFirestore.instance.collection("partie").doc(_partieID).update(<String, dynamic>{'lancee' : _estLancee});
 }

 bool isEstLancee(){
    return _estLancee;
 }

  void mettreAJourInstance(){
    FirebaseFirestore.instance.collection("partie").doc(_partieID).get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        _nom = data["nom"];
        _circuitID = data['circuit'];
        _partieID = data['partie'];
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }


  Future<void> mettreAJourBD() async{
    final data = <String, dynamic>{
      'nom': _nom,
      'circuit': _circuitID,
      'qrcode' : _qrCode
    };
    await FirebaseFirestore.instance.collection("partie").doc(_partieID).update(data);
  }

  ///Le constructeur qui permet de récupérer un circuit depuis la base de donnée
  ///
  factory Partie.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Partie(
      data?['nom'],
      snapshot.id,
      data?['circuit'],
      data?['qrCode'],
      data?['lancee']
    );
  }

  ///Lié à Circuit.fromFirestore()
  Map<String, dynamic> toFirestore() {
    return {
      if (_nom != null) "nom": _nom,
      if (_circuitID != null) "circuit": _circuitID,
      if (_qrCode != null) "qrCode" : _qrCode,
      'lancee' : _estLancee
    };
  }

  }