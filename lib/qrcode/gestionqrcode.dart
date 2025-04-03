import 'package:flutter/material.dart';
import 'package:tracks/qrcode/qrcodescanner.dart';
import 'package:tracks/pagesMobile/5_entrerNom.dart';
import 'package:tracks/pagesMobile/10_enigmeText.dart';

import '../back/circuit.dart';

/*
class GestionQRCode extends StatefulWidget {
  const GestionQRCode({super.key});

  @override
  State<GestionQRCode> createState() => _GestionQRCodeState();
}

class _GestionQRCodeState extends State<GestionQRCode> {
  String? _result;
  Circuit? _circuit;

  void setResult(String result) {
    setState(() => _result = result);
    //la fonction qui enregistre les données du qr code scanné dans _result
  }

  @override
  Widget build(BuildContext context) {
    //si c'est une partie
    if (_result != null && _result == 'p123456789'){
      //possibilité de rajouter des conditions ou des elseif au besoin
      //return bienvenue(); //la page vers laquelle ont veut rediriger après le scann du QR Code
      //une page enigme
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          iconTheme: IconThemeData(
            color: Colors.white, //couleur de la flèche retour en arrière
          ),
          //automaticallyImplyLeading: false, //pas de flèche retour en arrière
          backgroundColor: Color(0xFF4b8c72), // Couleur de fond VERT MOYEN
          elevation: 0,
        ),

        body: Container(
          color: const Color(0xFF4b8c72), // Couleur de fond VERT MOYEN
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(
                  width: 300,
                  child : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        const Text(
                          textAlign: TextAlign.center,
                          "Vous participez à la partie :",
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            color: Colors.white, // Texte en blanc pour être visible
                          ),
                        ),
                        const SizedBox(height: 15),

                        const Text(
                          textAlign: TextAlign.center,
                          "Nom de la partie",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white, // Texte en blanc pour être visible
                          ),
                        ),
                        const SizedBox(height: 50),

                        ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Page5(partieID: "Iha83fb3khaqhqRgzRTz",),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(300, 50), // Largeur: 300, Hauteur: 60
                          ),
                          child: const Text(
                            'Se connecter à un groupe',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3c735d), // Couleur du texte du bouton VERT FONCE
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
      //si c'est une enigme
    }else if (_result != null && _result == 'e123456789'){
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
                      onPressed: ()=> print("Click btn chrono"),
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
                            onPressed: (){},
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
                        child:Row(
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
                                color: Colors.white, // Texte en blanc pour être visible
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
                            color: Color(0xFF4b8c72), // Texte en blanc pour être visible
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
                            color: Color(0xFF4b8c72), // Texte en blanc pour être visible
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Page10(circuit: _circuit!,)), // Navigation
                      /*
                    if(enigme)
                      MaterialPageRoute(builder: (context) => Page10()), // Navigation vers page fin partie (13)
                    else
                      if(fin de partie)
                        MaterialPageRoute(builder: (context) => Page13()), // Navigation vers page fin partie (13)
                      else
                        MaterialPageRoute(builder: (context) => Page(7)), // Navigation vers page cherche lieux (7) vers nouveaux lieu
                    */
                    );
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
    }else{
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          iconTheme: IconThemeData(
            color: Colors.white, //couleur de la flèche retour en arrière
          ),
          //automaticallyImplyLeading: false, //pas de flèche retour en arrière
          backgroundColor: Color(0xFF4b8c72), // Couleur de fond VERT MOYEN
          elevation: 0,
        ),

        body: Container(
          color: const Color(0xFF4b8c72), // Couleur de fond VERT MOYEN
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QrCodeScanner(setResult: setResult),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(300, 50), // Largeur: 300, Hauteur: 60
                  ),
                  child: const Text(
                    'Scanner le QR code',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3c735d), // Couleur du texte du bouton VERT FONCE
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                Text(
                  _result ?? 'Merci de scanner un QrCode',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

/*
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_result ?? 'No result'),
            ElevatedButton(
              child: const Text('Scan QR code'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QrCodeScanner(setResult: setResult),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */
 */