import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracks/qrcode/qrcodescanner.dart';
import 'package:tracks/pagesMobile/6_debutPartie.dart';
import 'package:tracks/pagesMobile/9_enigmeImage.dart';
import 'package:tracks/pagesMobile/2_entrerPartie.dart';
import '../back/group.dart';
import '../back/partie.dart';
import '4_entrerCodePartie.dart';

//Color(0xFF3c735d) vert foncé
//Color(0xFF4b8c72) vert moyen
//Color(0xFF5ba788) vert clair

//Color(0xFFd9d9d9) gris clair

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => Page2state();
}

class Page2state extends State<Page2> {
  String? _result;
  late Partie? _partie;
  List<Group?> _lstGroup = [];
  late Group? _groupSelectionne;
  bool _partieValide = false;
  bool _groupeValide = false;

  bool _isEditingTextTitre = false;
  String? initialTextTitre;
  late TextEditingController _editingControllerTitre;

  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);
  static const Color grisClair = Color(0xFFe9e9e9);

  ///Initialisation des variables
  @override
  void initState() {
    super.initState();
    initTextEdit();
  }

  ///fonction dispose modifiée pour les zones de texte éditables
  @override
  void dispose() {
    setState(() {
      _editingControllerTitre.dispose();
    });
    super.dispose();
  }

  ///Initialise les variables liées aux textes éditables
  void initTextEdit() {
    setState(() {
      initialTextTitre = "";
      _editingControllerTitre = TextEditingController(text: initialTextTitre);
    });
  }

  void setResult(String result) {
    setState(() => _result = result);
    //la fonction qui enregistre les données du qr code scanné dans _result
  }

  //Vérifie que le QRCode scanné correspond bien à une partie existante
  Future<void> verifPartie(String idPartie) async {
    print("test verifPartie");
    final ref = FirebaseFirestore.instance
        .collection("partie")
        .doc(idPartie)
        .withConverter(
          fromFirestore: Partie.fromFirestore,
          toFirestore: (Partie partie, _) => partie.toFirestore(),
        );
    final docSnap = await ref.get();
    setState(() {
      _partie = docSnap.data();
    });
    if (_partie != null) {
      setState(() {
        _partieValide = true;
      });
    }
  }

  //faire sans groupes
  bool verifCodeGroupe(String code) {
    return true;
    for (int i = 0; i < _lstGroup!.length; i++) {
      if (_lstGroup[i]!.getCodeGroup() == code) {
        setState(() {
          _groupeValide = true;
          _groupSelectionne = _lstGroup[i];
        });
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_partieValide) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          iconTheme: IconThemeData(
            color: Colors.white, //couleur de la flèche retour en arrière
          ),
          //automaticallyImplyLeading: false, //pas de flèche retour en arrière
          backgroundColor: Color(0xFF3c735d), // Couleur de fond VERT FONCE
          elevation: 0,
        ),
        body: Container(
          color: const Color(0xFF3c735d), // Couleur de fond VERT FONCE
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).height - 350,
                  child: Center(
                    child: Column(
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
                                        'assets/images/logoSansFond.png',
                                        // Chemin de l'image du logo dans les assets
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
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "Entrez votre nom",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                _editTitleTextFieldTitre(),
                                const SizedBox(height: 10),

                                //bouton page suivante
                                ElevatedButton(
                                  onPressed: () {
                                    // Utilisation de Navigator pour naviguer vers EventPage
                                    if (verifCodeGroupe(initialTextTitre!)) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Page6(
                                                  partie: _partie!,
                                                  nom:
                                                      initialTextTitre! /*_groupSelectionne!.getNom()!*/,
                                                )), // Navigation
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color(0xFF5ba788), //VERT CLAIR
                                    shadowColor: Colors.transparent,
                                    minimumSize: const Size(
                                        300, 50), // Largeur: 300, Hauteur: 60
                                  ),
                                  child: const Text(
                                    "Suivant",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white, // Couleur du texte du bouton
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
    //si c'est une partie
    if (_result != null && _result!.length > 20 && _result?[0] == 'p') {
      verifPartie(_result!.substring(1));
      return Scaffold();
    } else {
//
//       return Scaffold(
//         appBar: AppBar(
//           toolbarHeight: 50,
//           iconTheme: IconThemeData(
//             color: Color(
//                 0xFF3c735d), //couleur de la flèche retour en arrière VERT FONCE
//           ),
//           //automaticallyImplyLeading: false, //pas de flèche retour en arrière
//           backgroundColor: Colors.white, // Couleur de fond VERT MOYEN
//           elevation: 0,
//         ),
//         body: Container(
//           color: Colors.white,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Container(
//                   height: MediaQuery.sizeOf(context).height - 200,
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         //Logo et intitulé de la page
//                         Container(
//                           width: 300,
//                           child: Center(
//                             child: Column(
//                               children: [
//                                 Center(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       //logo
//                                       Image.asset(
//                                         'assets/images/logoTracksVertFonce.png',
//                                         // Chemin de l'image du logo dans les assets
//                                         width: 150, // Redimensionne l'image
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const Text(
//                                   "Accéder à une partieeeeeeeeeeeeeeeeeeeee",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontFamily: 'Poppins',
//                                     color: Color(
//                                         0xFF3c735d), // Texte en blanc pour être visible
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         //contenu
//                         Container(
//                           width: 300,
//                           child: Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               // Aligner vers le haut
//                               children: [
//                                 //icon du code QR
//                                 Icon(
//                                   Icons.qr_code_scanner,
//                                   size: 110,
//                                   color: Color(0xFF3c735d),
//                                 ),
//                                 const SizedBox(height: 20),
//
//                                 //bouton scan QR code
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     // Utilisation de Navigator pour naviguer
//                                     Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => QrCodeScanner(
//                                                 setResult: setResult,
//                                               )), // Navigation
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Color(0xFF3c735d),
//                                     //VERT FONCE
//                                     shadowColor: Colors.transparent,
//                                     minimumSize: const Size(
//                                         300, 50), // Largeur: 300, Hauteur: 60
//                                   ),
//                                   child: const Text(
//                                     "Scanner un Qr code",
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors
//                                           .white, // Couleur du texte du bouton VERT FONCE
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 50),
// /*
//                                 const Text(
//                                   "ou",
//                                   style: TextStyle(
//                                     fontSize: 20,
//                                     color: Color(0xFF4b8c72),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 50),
//
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     // Utilisation de Navigator pour naviguer
//                                     Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(builder: (context) =>
//                                           Page4()), // Navigation
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Color(0xFF3c735d),
//                                     //VERT FONCE
//                                     shadowColor: Colors.transparent,
//                                     minimumSize: const Size(
//                                         300, 50), // Largeur: 300, Hauteur: 60
//                                   ),
//                                   child: const Text(
//                                     "Entrer un code",
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors
//                                           .white, // Couleur du texte du bouton
//                                     ),
//                                   ),
//                                 ),*/
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
      return Scaffold(
        body: Stack(
          children: [
            //Image en arrière-plan
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/background.png'), // Chemin de l'image de fond dans les assets
                  fit: BoxFit.cover, // L'image couvre tout l'écran
                ),
              ),
            ),

            //Contenu au-dessus de l'image
            Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //texte
                    Container(
                      width: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              textAlign: TextAlign.center,
                              "Bienvenue sur",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .white, // Texte en blanc pour être visible sur l'image
                              ),
                            ),

                            const SizedBox(height: 10),

                            //logo
                            Image.asset(
                              'assets/images/logoSansFond.png', // Chemin de l'image du logo dans les assets
                            ),
                            const SizedBox(height: 10),

                            const Text(
                              textAlign: TextAlign.center,
                              "Application de jeu de piste privé",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .white, // Texte en blanc pour être visible
                              ),
                            ),
                            const SizedBox(height: 40),

                            //bouton page suivante
                            ElevatedButton(
                              onPressed: () {
                                // Utilisation de Navigator pour naviguer
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QrCodeScanner(
                                            setResult: setResult,
                                          )), // Navigation
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                minimumSize: const Size(
                                    300, 50), // Largeur: 300, Hauteur: 60
                              ),
                              child: const Text(
                                "Entrer dans une partie",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      vertFonce, // Couleur du texte du bouton VERT FONCE
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
      );
    }
  }

  Widget _editTitleTextFieldTitre() {
    if (_isEditingTextTitre) {
      return Container(
        child: Column(
          children: [
            TextField(
              style: TextStyle(
                color: vertFonce,
                fontSize: 15,
              ),
              onSubmitted: (newValue) {
                setState(() {
                  initialTextTitre = newValue;
                  _isEditingTextTitre = false;
                });
              },
              autofocus: true,
              controller: _editingControllerTitre,
              decoration: new InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "ex : Jean",
                hintStyle: TextStyle(
                  color: vertClair,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.all(15),
                focusedBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white),
                  borderRadius: new BorderRadius.circular(150),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white),
                  borderRadius: new BorderRadius.circular(150),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  "Appui sur OK ou entrer pour valider",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
    return InkWell(
      onTap: () {
        setState(() {
          _isEditingTextTitre = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          color: Color(0xFFf2f2f2),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              nomVide(),
              Icon(
                Icons.edit,
                color: vertClair,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget nomVide() {
    if (initialTextTitre != "") {
      return Text(
        initialTextTitre!,
        style: TextStyle(
          color: vertFonce,
          fontSize: 14,
        ),
      );
    }
    return Text(
      'ex : Jean',
      style: TextStyle(
        color: vertClair,
        fontSize: 14,
      ),
    );
  }
}
