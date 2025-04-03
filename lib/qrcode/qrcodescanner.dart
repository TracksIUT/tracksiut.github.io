import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

///Scanner de QRCode
class QrCodeScanner extends StatelessWidget {
  QrCodeScanner({
    required this.setResult,
    super.key,
  });

  final Function setResult;
  final MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Container(
                height: MediaQuery
                    .sizeOf(context)
                    .height - 150,
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

                      //contenu
                      Container(
                        width: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [

                              //scan
                              Container(
                                height: 400,
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.white,
                                      width: 2
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: MobileScanner(
                                    controller: controller,
                                    onDetect: (BarcodeCapture capture) async {
                                      final List<Barcode> barcodes = capture
                                          .barcodes;
                                      final barcode = barcodes.first;

                                      if (barcode.rawValue != null) {
                                        setResult(barcode.rawValue);

                                        await controller
                                            .stop()
                                            .then((value) =>
                                            controller.dispose())
                                            .then((value) =>
                                            Navigator.of(context).pop());
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              const Text(
                                "Scannez un Qr Code pour accéder à la page suivante",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
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