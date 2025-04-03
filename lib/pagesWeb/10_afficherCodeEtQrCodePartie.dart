import 'package:flutter/material.dart';



// Déclaration de la classe PartagePartie en tant que StatefulWidget, car l'interface peut changer dynamiquement
class PartagePartie extends StatefulWidget {
  @override
  _PartagePartie createState() => _PartagePartie();
}

class _PartagePartie extends State<PartagePartie> {
  static const Color vertMoyen = Color(0xFF4b8c72);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        toolbarHeight: 120, // Hauteur de la barre d'outils
        backgroundColor:
        vertMoyen, // Couleur de fond de la barre d'outils

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/logoSansFond.png',
                  height: 80, // Taille de l'image
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgroundWeb.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Partie 1",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        // Icône QR code avec fond blanc
                        const Text(
                          "Scanner le QR code",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20), // Espacement vertical
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.qr_code, // Icône de QR code
                            size: 130,
                            color: Colors.black, // Couleur de l'icône
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 200),

                    // Colonne pour le champ de saisie du code de la partie
                    Column(
                      children: [
                        const Text(
                          "Entrer le code",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Champ de saisie pour entrer le code
                        Container(
                          width: 100, // Largeur du champ de saisie
                          child: TextFormField(
                            textAlign: TextAlign.center, // Centrage du texte
                            decoration: InputDecoration(
                              hintText:
                                  '44444', // Texte d'exemple dans le champ
                              hintStyle: TextStyle(color: Color(0X1F000000), fontSize: 22),
                              filled: true,
                              fillColor: Colors.white, // Fond blanc
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(8), // Coins arrondis
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ],

                ),

                // const SizedBox(height: 30), // Espacement vertical
                // const Text(
                //   "OU",
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontFamily: 'Poppins',
                //     color: Colors.white,
                //   ),
                // ),
                const SizedBox(height: 50),

                // Affichage du nombre de participants connectés
                const Text(
                  "Nombre de participants \n         connectés : 0",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40), // Espacement vertical

                // Boutons "Annuler" et "Suivant"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Bouton "Annuler"
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        textStyle: const TextStyle(fontSize: 14),
                        backgroundColor:Colors.white,
                        fixedSize: const Size(200, 60),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Retour à l'écran précédent
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close,
                            color : vertMoyen,
                            size: 40.0,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Annuler",
                            style: TextStyle(color: vertMoyen, fontSize: 20,),
                          ),

                        ],
                      ),
                    ),
                    // Bouton "Suivant"

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        textStyle: const TextStyle(fontSize: 14),
                        backgroundColor:Colors.white,
                        fixedSize: const Size(200, 60),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Retour à l'écran précédent
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Suivant",
                            style: TextStyle(
                                color: vertMoyen,
                              fontSize: 20,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color :vertMoyen,
                            size: 40.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
