import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracks/pagesWeb/1_bienvenue.dart';
import 'package:tracks/back/pointpassage.dart';
import 'package:tracks/back/circuit.dart';
import 'package:tracks/pagesWeb/1_bienvenue.dart';
import 'package:tracks/pagesWeb/4_accueil.dart';

/***
 * 1. Recuperer les infos
 *
 * Pour suppressions :
 * 1. supprimer circuit
 * 2. partie et enigme
 * 3. a la fin supprimer user
 */
class profile extends StatefulWidget {
  final String userID;

  profile({super.key, required this.userID});

  @override
  State<StatefulWidget> createState() => _profile(userID);
}

class _profile extends State<profile> {
  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);
  static const Color grisClair = Color(0xFFd9d9d9);

  final String userID;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  _profile(this.userID);

  List<String>? _lstCircuitID = [];

  String _mailUser = "";

  ///récupère les données de l'utilisateur dans la base de donnée
  Future<void> getUserData() async {
    print("getUserData");
    final docRef = FirebaseFirestore.instance.collection("users").doc(userID);
    final test = docRef.get();
    final user = await test.then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data;
      },
      onError: (e) => print("Error getting document: $e"),
    );
    setState(() {
      _mailUser = user["email"];
      _lstCircuitID =
          user['lstCircuit'] is Iterable ? List.from(user['lstCircuit']) : null;
    });
  }

  @override
  void initState() {
    super.initState();
    _mailUser = _auth.currentUser?.email ?? "Utilisateur inconnu";
    getUserData();
  }

  ///Récupère le circuit à modifier depuis la Base de Données
  ///
  /// Initialise les variables de sauvegarde
  Future<void> supprimerCircuits() async {
    for (int i = 0; i < _lstCircuitID!.length; i++) {
      print("Je suis dedans");
      final ref = FirebaseFirestore.instance
          .collection("circuit")
          .doc(_lstCircuitID![i])
          .withConverter(
            fromFirestore: Circuit.fromFirestore,
            toFirestore: (Circuit circuit, _) => circuit.toFirestore(),
          );
      final docSnap = await ref.get();
      Circuit? circuit = docSnap.data();
      circuit!.supprimerCircuit();
    }
  }

  void deleteDocument(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection("users") // Spécifiez le nom de votre collection
          .doc(docId) // Spécifiez l'ID du document à supprimer
          .delete();

      print('Document supprimé avec succès');
    } catch (e) {
      print('Erreur lors de la suppression : $e');
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
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AccueilWeb(userID: widget.userID)),
                );
              },
              child: const Text("Accueil", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            Expanded(
              child: Center(child: Image.asset('assets/images/logoSansFond.png', height: 80)),
            ),
            Icon(Icons.account_circle_sharp, color: Colors.white, size: 25),
            const SizedBox(width: 15),
            Text(_mailUser, style: const TextStyle(fontSize: 16, color: Colors.white)),
            const SizedBox(width: 15),
          ],
        ),
      ),
      body: Center(
        child: Card(
          color: Colors.white,
          child: Container(
            width: 400.0,
            height: 400.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.account_circle_sharp, color: vertMoyen, size: 100),
                const SizedBox(height: 15),
                const Text('Profil de l\'utilisateur', style: TextStyle(color: vertMoyen)),
                const SizedBox(height: 15),
                Text(_mailUser, style: TextStyle(color: vertMoyen)),
                const SizedBox(height: 15),

                // Bouton de déconnexion
                ElevatedButton(
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => bienvenueWeb()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(255, 78, 44, 1)),
                  child: const Text('Se déconnecter', style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(height: 15),

                // Bouton pour demander la suppression
                ElevatedButton(
                  onPressed: () => _sendDeleteConfirmation(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Supprimer le compte', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendDeleteConfirmation() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: "Aucun utilisateur n'est connecté.");
      }

      // On envoie un email de vérification
      await user.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Un email de confirmation vous a été envoyé. Cliquez sur le lien pour finaliser la suppression.")),
      );

      // Supprime le compte uniquement après confirmation de l'email
      _checkAndDeleteAccount(user);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

// Vérifie si l'utilisateur a confirmé l'email avant de supprimer son compte
  Future<void> _checkAndDeleteAccount(User user) async {
    // Attendre un peu pour que l'email de vérification soit traité
    await Future.delayed(Duration(seconds: 5));  // Par exemple 5 secondes

    await user.reload();  // Recharge l'état de l'utilisateur
    user = _auth.currentUser!;  // Met à jour l'utilisateur

    if (user!.emailVerified) {
      try {
        // Supprime les données Firestore associées
        await FirebaseFirestore.instance.collection("users").doc(widget.userID).delete();

        // Supprime l'utilisateur
        await user.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte supprimé avec succès !")),
        );

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => bienvenueWeb()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    } else {
      // Si l'email n'est pas vérifié, affiche un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez vérifier votre email avant de supprimer votre compte.")),
      );
    }
  }

}


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: grisClair,
//       appBar: AppBar(
//         scrolledUnderElevation: 0,
//         toolbarHeight: 120,
//         backgroundColor: vertMoyen,
//         automaticallyImplyLeading: false, //pas de flèche retour en arrière
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const SizedBox(width: 15),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => AccueilWeb(userID: userID)),
//                 );
//               },
//               child: Text("Accueil",
//                   style: TextStyle(fontSize: 16, color: Colors.white)),
//             ),
//             Expanded(
//               child: Center(
//                 child:
//                     Image.asset('assets/images/logoSansFond.png', height: 80),
//               ),
//             ),
//             Icon(
//               Icons.account_circle_sharp,
//               color: Colors.white,
//               size: 25,
//             ),
//             const SizedBox(width: 15),
//             Text(_mailUser,
//                 style: const TextStyle(fontSize: 16, color: Colors.white)),
//             const SizedBox(width: 15),
//           ],
//         ),
//       ),
//       body: Center(
//         child: Card(
//             color: Colors.white,
//             child: Container(
//               width: 400.0, // Largeur de la Card
//               height: 400.0, // Hauteur de la Card
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Icon(Icons.account_circle_sharp,
//                       color: vertMoyen, size: 100), // Icône à gauche
//
//                   const SizedBox(height: 15),
//
//                   const Text('Profil de l\'utilisateur',
//                       style: TextStyle(color: vertMoyen)),
//
//                   const SizedBox(height: 15),
//
//                   Text(_mailUser, style: TextStyle(color: vertMoyen)),
//
//                   const SizedBox(height: 15),
//
//                   ElevatedButton(
//                     onPressed: () {
//                       try {
//                         FirebaseAuth.instance.signOut();
//                         // Redirige l'utilisateur vers la page de connexion ou autre
//                         print("Déconnexion réussie");
//                       } catch (e) {
//                         print("Erreur lors de la déconnexion : $e");
//                       }
//                       Navigator.of(context).push(MaterialPageRoute(
//                           builder: (context) => bienvenueWeb()));
//                       Text('Se déconnecter');
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color.fromRGBO(255, 78, 44, 1),
//                     ),
//                     child: const Text(
//                       'Se déconnecter',
//                       style: TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   ElevatedButton(
//                     onPressed: () {
//                       showDialog(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           backgroundColor: grisClair,
//                           title: const Text("Suppression du compte"),
//                           content: Text(
//                               "Vous êtes sur de vouloir supprimer votre compte ?"),
//                           actions: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                               },
//                               style: TextButton.styleFrom(
//                                 backgroundColor:
//                                     Colors.white, // Couleur de fond
//                                 foregroundColor:
//                                     Colors.black, // Couleur du texte
//                               ),
//                               child: const Text("Non"),
//                             ),
//                             TextButton(
//                               onPressed: () {
//
//                                 supprimerCircuits();
//                                 deleteDocument(userID);
//                                 try {
//                                   // Récupérer l'utilisateur actuel
//                                   User? user =
//                                       FirebaseAuth.instance.currentUser;
//
//                                   if (user != null) {
//                                     // Supprimer l'utilisateur
//                                     user.delete();
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                           content: Text(
//                                               "Compte supprimé avec succès")),
//                                     );
//                                   } else {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                           content: Text(
//                                               "Aucun utilisateur connecté")),
//                                     );
//                                   }
//                                 } catch (e) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text("Erreur : $e")),
//                                   );
//                                 }
//
//                                 Navigator.of(context).push(MaterialPageRoute(
//                                     builder: (context) => bienvenueWeb()));
//                               },
//                               style: TextButton.styleFrom(
//                                 backgroundColor:
//                                     Colors.white, // Couleur de fond
//                                 foregroundColor:
//                                     Colors.black, // Couleur du texte
//                               ),
//                               child: const Text("Oui"),
//                             ),
//                           ],
//                         ),
//                       );
//                       Text('Supprimer le compte');
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                     ),
//                     child: const Text(
//                       'Supprimer le compte',
//                       style: TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )),
//       ),
//     );
//   }
// }
