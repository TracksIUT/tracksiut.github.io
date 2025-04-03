// import 'package:flutter/material.dart';
// import '2_entrerPartie.dart';
// import 'package:tracks/qrcode/qrcodescanner.dart';
//
//
// class bienvenue extends StatelessWidget {
//   const bienvenue({super.key});
//   static const Color vertFonce = Color(0xFF3c735d);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           //Image en arrière-plan
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/images/background.png'), // Chemin de l'image de fond dans les assets
//                 fit: BoxFit.cover, // L'image couvre tout l'écran
//               ),
//             ),
//           ),
//
//           //Contenu au-dessus de l'image
//           Container(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//
//                   //texte
//                   Container(
//                     width: 300,
//                     child : Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//
//                           const Text(
//                             textAlign: TextAlign.center,
//                             "Bienvenue sur",
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white, // Texte en blanc pour être visible sur l'image
//                             ),
//                           ),
//
//                           const SizedBox(height: 10),
//
//                           //logo
//                           Image.asset(
//                             'assets/images/logoSansFond.png', // Chemin de l'image du logo dans les assets
//                           ),
//                           const SizedBox(height: 10),
//
//                           const Text(
//                             textAlign: TextAlign.center,
//                             "Application de jeu de piste privé",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white, // Texte en blanc pour être visible
//                             ),
//                           ),
//                           const SizedBox(height: 40),
//
//                           //bouton page suivante
//                           ElevatedButton(
//                             onPressed: () {
//                               // Utilisation de Navigator pour naviguer
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => Page2()), // Navigation
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               shadowColor: Colors.transparent,
//                               minimumSize: const Size(300, 50), // Largeur: 300, Hauteur: 60
//                             ),
//                             child: const Text(
//                               "Entrer dans une partie",
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold,
//                                 color: vertFonce, // Couleur du texte du bouton VERT FONCE
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
