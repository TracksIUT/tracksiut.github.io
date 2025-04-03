import 'package:flutter/material.dart';
import 'package:tracks/pagesWeb/2_creerCompte.dart';
import 'package:tracks/pagesWeb/3_connexion.dart';

const Color vertFonce = Color(0xFF3c735d);

class bienvenueWeb extends StatelessWidget {
  const bienvenueWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image en arrière-plan
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/backgroundWeb.png'), // Chemin de l'image de fond dans les assets
                fit: BoxFit.cover, // L'image couvre tout l'écran
              ),
            ),
          ),

          // Contenu au-dessus de l'image
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Bienvenue sur",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors
                        .white, // Texte en blanc pour être visible sur l'image
                  ),
                ),

                //logo
                Image.asset(
                  'assets/images/logoSansFond.png', // Chemin de l'image du logo dans les assets
                  width: 300, // Redimensionne l'image
                ),

                //texte
                Container(
                  width: 300,
                  child: Center(
                    child: Column(
                      children: [
                        const Text(
                          textAlign: TextAlign.center,
                          "Gestion de l’application de jeu de piste",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white, // Texte en blanc pour être visible
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                ElevatedButton(
                  onPressed: () {
                    // Utilisation de Navigator pour naviguer vers EventPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              page2()), // Navigation vers EventPage
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(250, 50),
                  ),
                  child: const Text(
                    "Créer un compte",
                    style: TextStyle(
                      fontSize: 18,
                      color: vertFonce, // Couleur du texte du bouton VERT FONCE
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                ElevatedButton(
                  onPressed: () {
                    // Utilisation de Navigator pour naviguer vers EventPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              page3()), // Navigation vers EventPage
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(250, 50),
                  ),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(
                      fontSize: 18,
                      color: vertFonce, // Couleur du texte du bouton VERT FONCE
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
