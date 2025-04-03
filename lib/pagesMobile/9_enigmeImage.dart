import 'package:flutter/material.dart';
import 'package:tracks/back/enigmeImage.dart';
import '../back/circuit.dart';
import '../back/enigme.dart';
import '../back/pointpassage.dart';
import '10_enigmeText.dart';

//Color(0xFF3c735d) vert foncé
//Color(0xFF4b8c72) vert moyen
//Color(0xFF5ba788) vert clair

//Color(0xFFd9d9d9) gris clair

class Page9 extends StatefulWidget {
  final Circuit circuit;
  final PointPassage pointPassage;
  final EnigmeImage enigme;
  final String idPartie;
  final String nom;
  const Page9(
      {super.key,
      required this.circuit,
      required this.pointPassage,
      required this.enigme,
      required this.idPartie,
      required this.nom});

  @override
  State<Page9> createState() =>
      _Page9State(circuit, pointPassage, enigme, idPartie, nom);
}

class _Page9State extends State<Page9> {
  Circuit _circuit;
  PointPassage _pointPassage;
  EnigmeImage _enigme;
  String _idPartie;
  String _nom;
  _Page9State(this._circuit, this._pointPassage, this._enigme, this._idPartie,
      this._nom);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 210,
        /*iconTheme: IconThemeData(
          color: Colors.white, //couleur de la flèche retour en arrière
        ),*/
        automaticallyImplyLeading: false, //pas de flèche retour en arrière
        backgroundColor: Color(0xFF4b8c72), // Couleur de fond VERT MOYEN
        elevation: 0,

        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //logo
                  Image.asset(
                    'assets/images/logoSansFond.png', // Chemin de l'image du logo dans les assets
                    width: 150, // Redimensionne l'image
                  ),

                  //chrono
                  ElevatedButton(
                    onPressed: () => print("Click btn chrono"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(10, 10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //icon time
                        IconButton(
                          icon: const Icon(Icons.timer_outlined),
                          color: Color(0xFF4b8c72), // VERT MOYEN
                          tooltip: 'Temp restant',
                          onPressed: () {},
                        ),

                        //temps
                        const Text(
                          "00:00",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4b8c72), // VERT MOYEN
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Column(
                children: [
                  const Text(
                    "Nom de la partie",
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      color: Colors.white, // Texte en blanc pour être visible
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    "Nom du groupe",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white, // Texte en blanc pour être visible
                    ),
                  ),
                  const SizedBox(height: 25),

                  //nom du lieu
                  Container(
                    width: 250,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_pin,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            "Nom du lieu",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              color: Colors
                                  .white, // Texte en blanc pour être visible
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //texte
              Container(
                width: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Description du lieu :",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(
                              0xFF4b8c72), // Texte en blanc pour être visible
                        ),
                      ),
                      const SizedBox(height: 20),

                      //description du lieu
                      const Text(
                        "Blablablablabalblablablablablablablablablablabalblablablablablablablab"
                        "lablablabalblablablablablablablablablablabalblablablablablablablab"
                        "lablablabalblablablablablablablablablablabalblablablablablablablab"
                        "lablablabalblablablablablablablablablablabalblablablablablablablabl"
                        "ablablabalblablablablablablablabla.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(
                              0xFF4b8c72), // Texte en blanc pour être visible
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //bouton page suivante
              ElevatedButton(
                onPressed: () {
                  // Utilisation de Navigator pour naviguer
                  /*
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Page10(
                              circuit: _circuit,
                              pointPassage: _pointPassage,
                              enigme: _enigme,
                              idPartie: _idPartie,
                              nom: _nom,
                            )), // Navigation
                    /*
                    if(enigme)
                      MaterialPageRoute(builder: (context) => Page9()), // Navigation vers page fin partie (13)
                    else
                      if(fin de partie)
                        MaterialPageRoute(builder: (context) => Page13()), // Navigation vers page fin partie (13)
                      else
                        MaterialPageRoute(builder: (context) => Page(7)), // Navigation vers page cherche lieux (7) vers nouveaux lieu
                    */
                  );*/
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4b8c72), //VERT MOYEN
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(300, 50), // Largeur: 300, Hauteur: 60
                ),
                child: const Text(
                  "Voir l’énigme",
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
    );
  }
}
