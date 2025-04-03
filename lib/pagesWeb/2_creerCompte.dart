import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pagesWeb/4_accueil.dart';
import '../pagesWeb/3_connexion.dart';



/*Navigator.pushReplacement : Cette méthode remplace la route actuelle par une nouvelle route sans permettre de revenir à la page précédente.
Si tu veux permettre de revenir en arrière, tu pourrais utiliser Navigator.push à la place.*/

class page2 extends StatefulWidget {
  const page2({super.key});

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<page2> {
  static const Color vertFonce = Color(0xFF3c735d);
  static const Color grisClair = Color(0xFFd9d9d9);

  // Controllers pour les champs email et mot de passe
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final List<String?> _lstCircuit = [];
  final List<String?> _lstEnigme =[];

  // Fonction pour créer un compte et enregistrer l'utilisateur dans Firestore
  Future<void> _createAccount() async {
    try {
      // Création du compte utilisateur avec Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Envoi de l'email de vérification
      await userCredential.user!.sendEmailVerification();
      // showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     backgroundColor: grisClair,
      //     title: const Text("Email de vérification"),
      //     content: Text(
      //         "Veuillez vérifier votre boîte mail pour confirmer votre adresse email."),
      //   ),
      // );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Un email de vérification vous a été envoyé. Veuillez vérifier votre boîte mail pour confirmer votre adresse email..")),
      );

      // Attendre la confirmation de l'utilisateur
      bool emailVerified = false;
      while (!emailVerified) {
        await Future.delayed(Duration(seconds: 2)); // Pause pour éviter la surcharge
        await userCredential.user!.reload(); // Recharge les infos de l'utilisateur
        emailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      }


      // Récupération de l'ID utilisateur
      String userId = userCredential.user!.uid;

      // Création d'un document dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': emailController.text.trim(),
        'createdAt': Timestamp.now(),
        'lstCircuit': _lstCircuit,
        'lstEnigme': _lstEnigme,
      });

      print("Utilisateur enregistré dans Firestore avec ID : $userId");

      // Redirection vers la page suivante
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AccueilWeb(userID: userId,)),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'Le mot de passe est trop faible.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Cet email est déjà utilisé.';
      } else if (e.code == 'invalid-email') {
        message = "L'email est invalide.";
      } else {
        message = 'Erreur : ${e.message}';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erreur"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image en arrière-plan
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgroundWeb.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Contenu au-dessus de l'image
          Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    width: 275,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //logo
                                Image.asset(
                                  'assets/images/logoSansFond.png',
                                  width: 500,
                                ),
                                const SizedBox(height: 20),

                                const Text(
                                  "Création d’un compte",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 40),

                                const Text(
                                  "Adresse mail",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Champ pour entrer l'adresse mail
                                SizedBox(
                                  width: 500,
                                  height: 40,
                                  child: TextField(
                                    controller: emailController,
                                    style: const TextStyle(
                                      color: vertFonce,
                                      fontSize: 15,
                                    ),
                                    // Décoration autour du champ texte (bordure, couleur de fond, etc.)
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'votre mail',
                                      hintStyle: const TextStyle(
                                        color: grisClair, // Couleur du texte indicatif GRIS CLAIR
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14.0,
                                        horizontal: 16.0,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                          width: 0.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                          width: 0.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),

                                const Text(
                                  "Mot de passe",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Champ pour entrer le mot de passe
                                SizedBox(
                                  width: 500,
                                  height: 40,
                                  child: TextField(
                                    controller: passwordController,
                                    obscureText: true,
                                    onSubmitted: (value) {
                                      // Appelé lorsque l'utilisateur appuie sur Entrée
                                      _createAccount();
                                    },
                                    style: const TextStyle(
                                      color: vertFonce,
                                      fontSize: 15,
                                    ),
                                    // Décoration autour du champ texte (bordure, couleur de fond, etc.)
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'votre mot de passe',
                                      hintStyle: const TextStyle(
                                        color: grisClair,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14.0,
                                        horizontal: 16.0,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                          width: 0.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                          width: 0.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Bouton pour créer le compte
                                ElevatedButton(
                                  onPressed: _createAccount,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(500, 50),
                                    shadowColor: Colors.transparent,
                                    backgroundColor: vertFonce,
                                    foregroundColor: Colors.transparent,
                                  ),
                                  child: const Text(
                                    "Créer mon compte",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white, // Couleur du texte du bouton VERT FONCE
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
