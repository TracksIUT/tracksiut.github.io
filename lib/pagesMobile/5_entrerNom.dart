import 'package:flutter/material.dart';
import '6_debutPartie.dart';

const Color vertFonce = Color(0xFF3c735d);
const Color vertClair = Color(0xFF5ba788);
const Color grisClair = Color(0xFFd9d9d9);

class EntrerNom extends StatefulWidget{
  final String partieID;
  const EntrerNom({super.key, required this.partieID});


  @override
  State<StatefulWidget> createState() => _EntrerNomstate(partieID);
}


class _EntrerNomstate extends State<EntrerNom> {
  final String _partieID;

  _EntrerNomstate(this._partieID);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 50,
        iconTheme: IconThemeData(
          color: Colors.white, //couleur de la flèche retour en arrière
        ),
        //automaticallyImplyLeading: false, //pas de flèche retour en arrière
        backgroundColor: vertFonce, // Couleur de fond VERT FONCE
        elevation: 0,
      ),

      body: Container(
        color: vertFonce, // Couleur de fond VERT FONCE
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Container(
                height: MediaQuery.sizeOf(context).height-275,
                child: Center(
                  child :Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      //Logo
                      Container(
                        width: 300,
                        child: Center(
                          child: Column(
                            children: [
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //logo
                                    Image.asset(
                                      'assets/images/logoSansFond.png', // Chemin de l'image du logo dans les assets
                                      width: 150, // Redimensionne l'image
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        width: 300,
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              const Text(
                                "Entrer le code de votre groupe",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 50),

                              //champ pour entrer le code du groupe
                              SizedBox(
                                width: 300, // Largeur réduite
                                height: 50, // hauteur réduite
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  // Style du texte saisi par l'utilisateur
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: vertFonce, // Couleur du texte VERT FONCE
                                  ),

                                  // Décoration autour du champ texte (bordure, couleur de fond, etc.)
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white, // Couleur de fond du TextField
                                    hintText: 'Entrez le code'+_partieID, // Texte indicatif à l'intérieur
                                    hintStyle: const TextStyle(
                                      color: grisClair, // Couleur du texte indicatif GRIS CLAIR
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14.0, // Taille verticale de l'intérieur du champ
                                      horizontal: 16.0, // Taille horizontale (espace autour du texte)
                                    ),
                                    //Champ inactif
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                        width: 0.0,          // Épaisseur de la bordure
                                      ),
                                    ),
                                    //Champ actif
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                        width: 0.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              //bouton page suivante
                              ElevatedButton(
                                onPressed: () {
                                  // Utilisation de Navigator pour naviguer vers EventPage

                                  /*Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => Page6(partie: "Iha83fb3khaqhqRgzRTz", codeGroupe: "azerty",)), // Navigation
                                  );*/
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: vertClair, //VERT CLAIR
                                  shadowColor: Colors.transparent,
                                  minimumSize: const Size(300, 50), // Largeur: 300, Hauteur: 60
                                ),
                                child: const Text(
                                  "Suivanteeee",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // Couleur du texte du bouton
                                  ),
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
        ),
      ),
    );
  }
}
