import 'package:flutter/material.dart';
import 'package:tracks/pagesWeb/tracksFooter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracks/back/circuit.dart';
import 'package:tracks/pagesWeb/6_editerCreerCircuit.dart';

class CreerOrdrePointPassagePage extends StatefulWidget {
  final String userID;
  final String? circuitID;

  const CreerOrdrePointPassagePage({
    super.key,
    required this.userID,
    required this.circuitID,
  });

  @override
  _CreerOrdrePointPassagePageState createState() =>
      _CreerOrdrePointPassagePageState();
}

class _CreerOrdrePointPassagePageState extends State<CreerOrdrePointPassagePage> {
  List<String> ordreModifiable = [];
  Map<String, String> nomsPointPassage = {}; // Stockage ID → Nom
  bool isLoading = true;
  Circuit? _circuit;
  String _mailUser = "";

  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color grisClair = Color(0xFFe9e9e9);

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  /// Récupère les informations de l'utilisateur et du circuit
  Future<void> getUserData() async {
    final userRef =
    FirebaseFirestore.instance.collection("users").doc(widget.userID);
    final userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      setState(() {
        _mailUser = userSnapshot.data()?["email"] ?? "";
      });
    }

    getCircuit();
  }

  /// Récupère `lstPointPassage` depuis Firebase
  Future<void> getCircuit() async {
    final ref = FirebaseFirestore.instance
        .collection("circuit")
        .doc(widget.circuitID);

    final docSnap = await ref.get();
    if (docSnap.exists) {
      setState(() {
        _circuit = Circuit.fromFirestore(docSnap, null);
        ordreModifiable = List.from(docSnap.data()?["lstPointPassage"] ?? []);
      });

      // Une fois la liste des IDs récupérée, on récupère les noms des points de passage
      await fetchPointPassageNames();
    }
  }

  /// Récupère les noms des points de passage depuis leurs IDs
  Future<void> fetchPointPassageNames() async {
    Map<String, String> tempNoms = {};

    for (String pointID in ordreModifiable) {
      final docRef =
      FirebaseFirestore.instance.collection("pointPassage").doc(pointID);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        String nom = docSnap.data()?["nom"] ?? "Point inconnu";
        tempNoms[pointID] = nom;
      } else {
        tempNoms[pointID] = "Point inconnu";
      }
    }

    setState(() {
      nomsPointPassage = tempNoms;
      isLoading = false;
    });
  }

  /// Sauvegarde le nouvel ordre des points de passage dans Firebase
  Future<void> saveOrdre() async {
    if (_circuit != null) {
      await FirebaseFirestore.instance
          .collection("circuit")
          .doc(widget.circuitID)
          .update({"lstPointPassage": ordreModifiable});

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CircuitCreationCircuit(circuitID: widget.circuitID!,userID: widget.userID)));
      //Navigator.pop(context, ordreModifiable);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClair,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 120,
        backgroundColor: vertMoyen,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Modifier l'ordre des Points de Passage",
              style:
              TextStyle(fontSize: 18, fontFamily: 'Poppins', color: Colors.white),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/logoSansFond.png',
                  height: 80,
                ),
              ),
            ),
            const Icon(Icons.account_circle_sharp, color: Colors.white, size: 25),
            const SizedBox(width: 15),
            Text(
              _mailUser,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loader pendant le chargement
          : Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Glissez et déposez pour réorganiser les points de passage",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: ReorderableListView(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: List.generate(ordreModifiable.length, (index) {
                    String pointID = ordreModifiable[index];
                    String nomPoint = nomsPointPassage[pointID] ?? "Chargement...";

                    return Card(
                      key: ValueKey(pointID),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: vertMoyen,
                          child: Text(
                            "${index + 1}", // Numérotation
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          nomPoint, // Affiche le nom
                          style: const TextStyle(fontSize: 18),
                        ),
                        trailing: const Icon(Icons.drag_handle),
                      ),
                    );
                  }),
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final String item = ordreModifiable.removeAt(oldIndex);
                      ordreModifiable.insert(newIndex, item);
                    });
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: vertMoyen,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
              ),
              onPressed: saveOrdre,
              child: const Text(
                "Enregistrer l'ordre",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          TracksFooter(context: context),
        ],
      ),
    );
  }
}
