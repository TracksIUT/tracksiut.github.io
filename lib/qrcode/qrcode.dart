import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Affichage d'un QR Code avec options de téléchargement et impression
class QRCode extends StatelessWidget {
  final String text; // Données à encoder dans le QR Code

  const QRCode({super.key, required this.text});

  // Couleurs utilisées
  static const Color vertFonce = Color(0xFF3c735d);
  static const Color vertMoyen = Color(0xFF4b8c72);
  static const Color vertClair = Color(0xFF5ba788);
  static const Color grisClair = Color(0xFFe9e9e9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code"),
        backgroundColor: vertFonce, // Couleur de l'en-tête
      ),
      body: Stack(
        children: [
          // Image d'arrière-plan
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Titre affiché au-dessus du QR Code
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "Un QRCode menant à une énigme",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              // Conteneur pour afficher le QR Code
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12), // Coins arrondis
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: QrImageView(
                    data: text, // Contenu du QR Code
                    version: QrVersions.auto,
                    size: 250, // Taille du QR Code
                    gapless: false,
                    backgroundColor: Colors.white, // Fond blanc
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Boutons pour télécharger ou imprimer le QR Code
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Bouton pour imprimer le QR Code
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Printing.layoutPdf(
                        onLayout: (PdfPageFormat format) =>
                            _generateQrCodePdf(format, text),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Imprimer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vertClair,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  // Bouton pour télécharger le QR Code en PDF
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Printing.sharePdf(
                        bytes: await _generateQrCodePdf(PdfPageFormat.a4, text),
                        filename: 'QRCode.pdf',
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Télécharger'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vertClair,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Génération d'un PDF contenant un QR Code
  Future<Uint8List> _generateQrCodePdf(PdfPageFormat format, String qrData) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'QR Code',
                  style: pw.TextStyle(font: font, fontSize: 24),
                ),
                pw.SizedBox(height: 20),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrData, // Contenu du QR Code
                  width: 200,
                  height: 200,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Scannez ce QR Code pour accéder au contenu',
                  style: pw.TextStyle(font: font, fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}

/// Génération d'un PDF contenant plusieurs QR Codes
Future<Uint8List> generateAllQrCodesPdf(
    PdfPageFormat format, String partieID, List<Map<String, String>> points) async {
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  final font = await PdfGoogleFonts.nunitoExtraLight();

  // Taille maximale par page (QR Codes avec titres)
  const int qrCodesPerPage = 9;

  // QR Codes à inclure : Partie et Points de passage
  final qrItems = [
  {'title': "Partie", 'data': 'p$partieID'}, // Partie (ID avec un 'p' devant)
  ...points.map((point) => {
  'title': "Point de passage : ${point['name']}", // Nom
  'data': 'e${point['id']}', // ID du point avec un 'e' devant
    }),
  ];

  // Génération des pages du PDF
  for (int i = 0; i < qrItems.length; i += qrCodesPerPage) {
    final pageItems = qrItems.sublist(
        i, i + qrCodesPerPage > qrItems.length ? qrItems.length : i + qrCodesPerPage);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            children: [
              pw.Text(
                'QR Codes',
                style: pw.TextStyle(font: font, fontSize: 24),
              ),
              pw.SizedBox(height: 20),
              pw.Wrap(
                spacing: 20,
                runSpacing: 20,
                children: pageItems.map((item) {
                  return pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        item['title'] ?? "Titre indisponible", // Nom
                        style: pw.TextStyle(font: font, fontSize: 12),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 10),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: item['data'] ?? "Données indisponibles", // Contenu
                        width: 100,
                        height: 100,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  return pdf.save();
}
