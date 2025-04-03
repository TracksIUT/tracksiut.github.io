import 'package:flutter/material.dart';


class TracksFooter extends StatelessWidget {
  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);
  static const Color grisClair = Color(0xFFd9d9d9);

  final BuildContext context;
  const TracksFooter({Key? key, required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Footer principal
        Container(
          color: vertMoyen, // Couleur de fond du footer
          height: 50,
          alignment: Alignment.center,
          child: Text(
            "@Copyright Blanchard Elyne, Barnezet Léa, Robert Benjamin, Renard Lucie",
            style: TextStyle(
              fontSize: 15,
              color: vertFonce, // Couleur du texte dans le footer
            ),
          ),
        ),
        // Bouton d'aide flottant
        Positioned(
          right: 15,
          bottom: 10,
          child: FloatingActionButton(
            onPressed: () {
              // Affiche une pop-up centrée avec flèches de navigation
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  final PageController pageController = PageController(); // Contrôleur pour le PageView

                  return Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.white, // Fond de la pop-up mis en blanc
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // Barre de fermeture
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              color: vertFonce, // Couleur de l'icône de fermeture
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                // PageView avec le contrôleur
                                PageView(
                                  controller: pageController,
                                  children: [
                                    _buildSlide(
                                      title: "Bienvenue sur TracksIUT",
                                      content: "TracksIUT vous permet de créer et de vivre des jeux de piste interactifs amusants, captivants, grâce à une application mobile innovante. Voici comment cela fonctionne, étape par étape...",
                                      titleColor: vertFonce, // Titre en vert foncé
                                      contentColor: Colors.black, // Contenu en noir
                                    ),
                                    _buildSlide(
                                      title: "Créer un Circuit avec des Points de Passage",
                                      content: "Tout commence par la création d’un circuit : Vous allez organiser un parcours avec des points de passage. Et pour ajouter du piment, chaque point peut être associé à une énigme. Les joueurs devront résoudre ces énigmes pour avancer ! C’est l’étape où l’imagination prend le dessus : créez des circuits originaux et des énigmes à la hauteur du défi !",
                                      titleColor: vertMoyen, // Titre en vert moyen
                                      contentColor: Colors.black, // Contenu en noir
                                    ),
                                    _buildSlide(
                                      title: "Créer une Partie",
                                      content: "Une fois le circuit préparé, vous pouvez créer la partie et associer le circuit à la partie que vous souhaitez lancer. C’est à ce moment-là que vous définissez les équipes.",
                                      titleColor: vertClair, // Titre en vert clair
                                      contentColor: Colors.black, // Contenu en noir
                                    ),
                                    _buildSlide(
                                      title: "Scanner pour Rejoindre la Partie",
                                      content: "Les joueurs rejoignent la partie en scannant un QR Code spécial dédié à la partie. Ce QR Code leur donne accès au jeu et marque le début de la Tracks !",
                                      titleColor: vertFonce, // Titre en vert foncé
                                      contentColor: Colors.black, // Contenu en noir
                                    ),
                                    _buildSlide(
                                      title: "Explorer le Circuit en Scannant les QR Codes",
                                      content: "Une fois dans la partie, les joueurs doivent se rendre de point de passage en point de passage. À chaque étape, un QR Code à scanner. Résoudre l’énigme suivante permet d’avancer au point suivant ! À vous de jouer.",
                                      titleColor: vertMoyen, // Titre en vert moyen
                                      contentColor: Colors.black, // Contenu en noir
                                    ),
                                    _buildSlide(
                                      title: "Lancez le Jeu !",
                                      content: "Tout est prêt ? Vous formez les groupes et appuyez sur le bouton 'Lancer' ! Les joueurs peuvent maintenant relever les défis, passer par tous les points de passage et compléter le circuit... à vous de briller !",
                                      titleColor: vertClair, // Titre en vert clair
                                      contentColor: Colors.black, // Contenu en noir
                                    ),
                                  ],
                                ),
                                // Flèche précédente
                                Positioned(
                                  left: 10,
                                  top: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back_ios),
                                    color: vertFonce, // Couleur de la flèche
                                    onPressed: () {
                                      // Passe à la page précédente
                                      if (pageController.hasClients) {
                                        final currentPage = pageController.page?.toInt() ?? 0;
                                        if (currentPage > 0) {
                                          pageController.animateToPage(
                                            currentPage - 1,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                                // Flèche suivante
                                Positioned(
                                  right: 10,
                                  top: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios),
                                    color: vertFonce, // Couleur de la flèche
                                    onPressed: () {
                                      // Passe à la page suivante
                                      if (pageController.hasClients) {
                                        final currentPage = pageController.page?.toInt() ?? 0;
                                        if (currentPage < 5) { // 5 correspond au nombre de pages - 1
                                          pageController.animateToPage(
                                            currentPage + 1,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            backgroundColor: vertClair, // Couleur du bouton flottant
            child: const Icon(Icons.help_outline, color: Colors.white), // Icône en blanc
          ),
        ),
      ],
    );
  }

  Widget _buildSlide({
    required String title,
    required String content,
    required Color titleColor,
    required Color contentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0), // Padding horizontal seulement
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: titleColor, // Couleur du titre
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 10),
            // Ajout d'un séparateur visuel entre le titre et le texte
            Container(
              height: 1, // Hauteur de la ligne
              color: Colors.grey, // Couleur de la ligne
              margin: const EdgeInsets.only(bottom: 10), // Marge pour espacer du contenu
            ),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: contentColor, // Couleur du contenu
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
