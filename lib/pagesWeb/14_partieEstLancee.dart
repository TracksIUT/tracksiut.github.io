import 'package:flutter/material.dart';
import 'package:tracks/back/partie.dart';
import 'package:tracks/pagesWeb/4_accueil.dart';

import '15_classement.dart';



const Color vertFonce = Color(0xFF3c735d);

class Page14 extends StatefulWidget {
  final Partie partie;
  final String userID;
  const Page14({super.key, required this.partie, required this.userID});

  @override
  _Page14 createState() => _Page14(partie, userID);
}

class _Page14 extends State<Page14> {
  Partie _partie;
  String _userID;

  _Page14(this._partie, this._userID);

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
                        Text(
                          textAlign: TextAlign.center,
                          "la partie : "+_partie.getNom()+" est lancée !",
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Classement(userID : _userID, partie: _partie,)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(250, 50),
                  ),
                  child: const Text(
                    "Voir le classement",
                    style: TextStyle(
                      fontSize: 18,
                      color: vertFonce, // Couleur du texte du bouton VERT FONCE
                    ),
                  ),
                ),
                const SizedBox(height: 15),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
