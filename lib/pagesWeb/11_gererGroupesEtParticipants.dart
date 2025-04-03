import 'package:flutter/material.dart';

/**
 * 1. modifier les constantes couleur pour tous les fichiers
 */

// Déclaration de la classe principale de l'application, qui est un StatefulWidget
class GestionGroupesParticipants extends StatefulWidget {
  @override
  _GestionGroupesParticipants createState() => _GestionGroupesParticipants();
}

// Classe d'état associée à la classe StatefulWidget
class _GestionGroupesParticipants extends State<GestionGroupesParticipants> {
 static const Color vertMoyen = Color(0xFF4b8c72);
 static const Color vertFonce = Color(0xFF3c735d);
 static const Color grisClair = Color(0xFFe9e9e9);
  // Liste des groupes contenant les noms des participants
  final List<List<String>> groupes = [
    ["Joueur 1", "Joueur 2", "Joueur 3", "Joueur 4","Joueur 4.5"], // Groupe 1
    ["Joueur 5", "Joueur 6", "Joueur 7", "Joueur 8","Joueur 8.1", "Joueur 8.2"], // Groupe 2
    ["Joueur 9", "Joueur 10", "Joueur 11", "Joueur 12"], // Groupe 3
    ["Joueur 13", "Joueur 14", "Joueur 15", "Joueur 16"], // Groupe 4
    ["Joueur 17", "Joueur 18", "Joueur 19", "Joueur 20"], // Groupe 5
    ["Joueur 21", "Joueur 22", "Joueur 23", "Joueur 24"], // Groupe 6
    ["Joueur 25", "Joueur 26", "Joueur 27", "Joueur 28"],
    ["Joueur 29", "Joueur 30", "Joueur 32", "Joueur 33"],
  ];

  final List<List<String>> code = [
    ["XXX3F3"],
    ["XXX3F4"],
    ["XXX3F5"],
    ["XXX3F6"],
    ["XXX3F7"],
    ["XXX3F8"],
    ["XXX3F9"],
    ["XXX3F10"],
  ];

  // Méthode build pour construire l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre d'application (AppBar)
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: vertMoyen, // Couleur de fond de la barre
        toolbarHeight: 100, // Hauteur de la barre
        title: Center(
          child: Image.asset(
            'assets/images/logoSansFond.png', // Logo affiché au centre
            height: 80, // Hauteur du logo
          ),
        ),
      ),
      // Corps principal de l'application
      body: Stack(
        children: [
          // Fond coloré
          Container(
            color: vertMoyen,
          ),
          // Contenu principal avec des marges
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
            child: Column(
              children: [
                // Titre principal
                const Text(
                  "Partie 1",
                  style: TextStyle(
                    fontSize: 24, // Taille de la police
                    fontWeight: FontWeight.bold, // Texte en gras
                    color: Colors.white, // Couleur blanche
                  ),
                ),
                const SizedBox(height: 8), // Espacement vertical
                // Sous-titre descriptif
                const Text(
                  "Récapitulatif des groupes et des participants de la partie, dernière étape avant de jouer !",
                  textAlign: TextAlign.center, // Centrer le texte
                  style: TextStyle(color: Colors.white), // Couleur blanche
                ),
                const SizedBox(height: 24), // Espacement vertical
                // Liste des groupes affichée sous forme de grille
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Nombre de colonnes
                      mainAxisSpacing:
                          8.0, // Espacement vertical entre les cartes
                      crossAxisSpacing:
                          8.0, // Espacement horizontal entre les cartes
                      childAspectRatio:
                          2 / 1, // Rapport largeur/hauteur des cartes ajusté
                    ),

                    itemCount: groupes.length, // Nombre de groupes
                    itemBuilder: (context, index) {
                      // Construire une carte pour chaque groupe
                      return buildGroupeCard(
                          index + 1, groupes[index], code[index]);
                    },
                  ),
                ),
                const SizedBox(height: 16), // Espacement avant le bouton
                // Bouton pour débuter la partie
                ElevatedButton(
                  onPressed: () {
                    // Action déclenchée lors du clic sur le bouton
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Fond blanc
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Boutons arrondis
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 8), // Espacement entre l'icône et le texte
                      Text(
                        "Débuter la partie",
                        style: TextStyle(
                          color: vertMoyen, // Texte en vert
                          fontSize: 16, // Taille de la police
                        ),
                      ),
                      Icon(Icons.play_arrow,
                          color: vertMoyen, size: 30), // Icône à gauche
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire une carte (Card) affichant les informations d'un groupe
 Widget buildGroupeCard(
     int groupeIndex, List<String> joueurs, List<String> codes) {
   return Card(
     color: grisClair, // Couleur de fond blanche
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(10), // Coins arrondis de la carte
     ),
     child: Padding(
       padding: const EdgeInsets.all(8.0), // Marges internes uniformes
       child: Column(
         children: [
           // Titre du groupe
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Row(
                 children: [
                   Text(
                     "Groupe $groupeIndex",
                     style: const TextStyle(
                       fontSize: 18, // Taille de police
                       fontWeight: FontWeight.bold, // Texte en gras
                       color: vertMoyen,
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 15), // Espacement vertical

               // Liste des codes du groupe
               Row(
                 children: [
                   ...codes.map((code) => Container(
                     padding: const EdgeInsets.all(7.0),
                     margin: const EdgeInsets.all(3),
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(20),
                       color: vertFonce,
                     ),
                     child: Text(
                       code, // La variable `code` contient un élément de la liste.
                       style: const TextStyle(
                         color: Colors.white,
                         fontSize: 18,
                       ),
                     ),
                   )),
                 ],
               ),
             ],
           ),
           const SizedBox(height: 15), // Espacement vertical

           // Liste des joueurs du groupe affichée deux par deux
           Container(
             color: Colors.red,
              width: 200,
              child: Column(children: chunkList(joueurs, 2).map((pair) {
                   return Row(
                     children: pair.map((joueur) {
                       return Expanded(
                         child: Container(
                           padding: const EdgeInsets.all(7.0),
                           margin: const EdgeInsets.all(3),
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(20),
                             color: Colors.white,
                           ),
                           child: Text(
                             joueur,
                             textAlign: TextAlign.center, // Centrer le texte
                             style: const TextStyle(
                               color: vertFonce,
                               fontSize: 13,
                             ),
                           ),
                         ),
                       );
                     }).toList(),
                   );
                 }).toList(),
               ),
           ),
         ],
       ),
     ),
   );
 }

 /// Fonction pour diviser une liste en sous-listes de taille égale (taille par défaut = 2)
 List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
   List<List<T>> chunks = [];
   for (int i = 0; i < list.length; i += chunkSize) {
     chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
   }
   return chunks;
 }
}
