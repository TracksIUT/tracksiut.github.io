import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '4_accueil.dart';



class page3 extends StatefulWidget {
  const page3({super.key});

  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<page3> {
 static const Color vertFonce = Color(0xFF3c735d);
 static const Color grisClair = Color(0xFFd9d9d9);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Fonction de connexion
  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Si la connexion réussit, naviguez vers la page d'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AccueilWeb(userID: userCredential.user!.uid)),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'Aucun utilisateur trouvé avec cet e-mail.';
      } else if (e.code == 'wrong-password') {
        message = 'Le mot de passe est incorrect.';
      } else {
        message = 'Erreur : ${e.message}';
      }

      // Affichage d'un message d'erreur
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
                                // Logo
                                Image.asset(
                                  'assets/images/logoSansFond.png',
                                  width: 500,
                                ),
                                const SizedBox(height: 20),

                                const Text(
                                  "Connexion",
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
                                      _signIn();
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

                                // Bouton pour se connecter
                                ElevatedButton(
                                  onPressed: _signIn,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(500, 50),
                                    shadowColor: Colors.transparent,
                                    backgroundColor: vertFonce,
                                    foregroundColor: Colors.transparent,
                                  ),
                                  child: const Text(
                                    "Se connecter",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
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
