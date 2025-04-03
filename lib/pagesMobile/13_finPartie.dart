import 'package:flutter/material.dart';
import '2_entrerPartie.dart';
import 'package:tracks/back/joueur.dart';
import '../back/circuit.dart';

class Page13 extends StatefulWidget {
  final Circuit circuit;
  final String tempsEcoule;
  final String idPartie;
  final String nom;

  const Page13(
      {Key? key,
      required this.circuit,
      required this.tempsEcoule,
      required this.idPartie,
      required this.nom})
      : super(key: key);

  @override
  _Page13State createState() => _Page13State(circuit, idPartie, nom);
}

class _Page13State extends State<Page13> {
  Circuit _circuit;
  static const Color vertMoyen = Color(0xFF4b8c72);
  String _idPartie;
  String _nom;
  _Page13State(this._circuit, this._idPartie, this._nom);

  @override
  void initState() {
    super.initState();
    _creeJoueur();
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
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenu de la page
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logoSansFond.png',
                          width: 275,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Fin de la partie",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Nom de la partie",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Votre groupe",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Nom du groupe",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Votre place dans le classement",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(10, 50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.emoji_events, color: vertMoyen),
                              SizedBox(width: 5),
                              Text(
                                "5ème",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: vertMoyen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Votre temps",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(10, 50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer_outlined,
                                  color: vertMoyen),
                              const SizedBox(width: 5),
                              Text(
                                widget.tempsEcoule,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: vertMoyen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            print("Revenir à l'accueil");
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Page2(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: const Text(
                            "Revenir à l'accueil",
                            style: TextStyle(
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                              decorationThickness: 2,
                              color: Colors.white,
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
        ],
      ),
    );
  }

  int score(){
    return _circuit.getLstPointPassage()!.length;
  }

  Future<void> _creeJoueur() async {
    print("Création d'un joueur...");

    Joueur newJoueur = Joueur(
      nom: _nom,
      idPartie: _idPartie,
      nbrPointPassageRestant: score(),
      chrono: widget.tempsEcoule, // Utilisation correcte du chrono
    );

    await newJoueur.saveToFirestore(); // Ajouter le joueur à Firestore

    print("Joueur ajouté à Firestore !");
  }
}
