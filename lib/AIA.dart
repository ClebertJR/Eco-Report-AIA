import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:impactos_ambientais/helpers/RegistroHelper.dart';
import 'package:impactos_ambientais/model/Registro.dart';
import 'dart:io';
import 'home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AIA extends StatefulWidget {
  const AIA({Key? key}) : super(key: key);

  @override
  _AIAState createState() => _AIAState();
}

class _AIAState extends State<AIA> {
  //Função que retorna caixa de registro de impactos.
  String dropdownValue = 'Selecione um Impacto';
  TextEditingController descricaoController = TextEditingController();

  exibirTelaCadastro() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Adicionar Informações"),
            backgroundColor: Colors.white,
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_drop_down_circle),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.blue),
                        underline: Container(height: 2, color: Colors.blue),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: <String>[
                          'Selecione um Impacto',
                          'Abertura artificial do estuário',
                          'Caminhos nos manguezais',
                          'Deposição de resíduos sólidos (Lixo)',
                          'Degradação da vegetação',
                          'Emissão de efluentes domésticos',
                          'Erosão do solo',
                          'Expansão urbana',
                          'Irrigação (Rio)',
                          'Morte do manguezal',
                          'Obstrução do canal',
                          'Pesca (Manguezal)',
                          'Pontes',
                          'Recreação (Mangue)',
                          'Outros'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()),
                    TextField(
                      controller: descricaoController,
                      decoration: InputDecoration(
                          labelText: "Observações", hintText: "Digite aqui..."),
                    )
                  ],
                );
              },
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.white))),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.deepPurple),
                  ),
                  child: Text(
                    "OK",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ))
            ],
          );
        });
  }

  //Função que retorna o toast do botão salvar
  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text(
          'Registro de impacto salvo com sucesso',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        //action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  //Função para pegar localização do impacto ambiental
  var localizacaoMensagem = "";
  void getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    var lat = position.latitude;
    var long = position.longitude;
    print("$lat , $long");

    setState(() {
      localizacaoMensagem = "Latitude: $lat, Longitude: $long";
    });
  }

  //Função camera
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;

  _imageFromCamera() async {
    _image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (_image != null) {
      setState(() {
        file = File(_image!.path);
      });
      saveInStorage(file!);
    }
  }

  _imageFromGallery() async {
    _image = await _picker.pickImage(source: ImageSource.gallery);
    if (_image != null) {
      setState(() {
        file = File(_image!.path);
      });
      saveInStorage(file!);
    }
  }

  // Permissão para salvar imagem no dispositivo
  Future<void> _checkPermission() async {
    var statusStorage = await Permission.storage.status;

    if (!statusStorage.isGranted) {
      await Permission.storage.request();
    }
  }

  String? caminho;
  Future<void> saveInStorage(File file) async {
    await _checkPermission();
    var statusStorage = await Permission.storage.status;

    if (statusStorage.isGranted) {
      try {
        final Directory _appDocDir = await getApplicationDocumentsDirectory();

        final Directory _appDocDirFolder = Platform.isIOS
            ? Directory('${_appDocDir.path}/Impactos Ambientais')
            : Directory('/storage/emulated/0/Impactos Ambientais');

        String filePath;

        if (await _appDocDirFolder.exists()) {
          filePath = _appDocDirFolder.path;
        } else {
          final Directory _appDocDirNewFolder =
              await _appDocDirFolder.create(recursive: true);
          filePath = _appDocDirNewFolder.path;
        }
        caminho = filePath;
        var format = file.path.split('.').last;
        debugPrint(filePath);

        await file.copy('$filePath/${timestamp()}.$format');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Salvo com sucesso na pasta Impactos Ambientais',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint('Não tem permisssão para salvar o arquivo');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não tem permisssão para salvar o arquivo',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //Função para escolher galeria ou camera
  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Foto da galeria'),
                onTap: () {
                  _imageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Foto da camera'),
                onTap: () {
                  _imageFromCamera();
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  //Função salvar dados checklist no banco
  RegistroHelper _db = RegistroHelper();
  void _salvar() async {
    Registro obj = Registro(caminho, dropdownValue, descricaoController.text,
        localizacaoMensagem, DateTime.now().toString());
    int resultado = await _db.inserirRegistro(obj);
    // ignore: unnecessary_null_comparison
    if (resultado != null) {
      print("Registro cadastrado com sucessso " + resultado.toString());
    } else {
      print("Erro ao cadastrar!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.home, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Checklist"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/assets/backgroundAIA.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(50),
                child: file == null
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        width: 250,
                        height: 300,
                        child: GestureDetector(
                          onTap: () {
                            _showPicker(context);
                          },
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 90,
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      "Clique para capturar imagem",
                                      style: TextStyle(color: Colors.white),
                                    ))
                              ]),
                        ),
                      )
                    : Image.file(
                        file!,
                        width: 250,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
              ),
              Padding(
                  padding: EdgeInsets.zero,
                  // ignore: deprecated_member_use
                  child: ElevatedButton(
                    onPressed: () {
                      exibirTelaCadastro();
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.white))),
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.description,
                          color: Colors.white,
                        ),
                        Text(
                          "Adiconar detalhes do impacto",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )),
              Padding(
                padding: EdgeInsets.only(top: 50),
                child: Icon(
                  Icons.location_on,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.zero,
                child: Text(
                  "$localizacaoMensagem",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 5),
                  // ignore: deprecated_member_use
                  child: ElevatedButton(
                    onPressed: () {
                      getCurrentLocation();
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.white))),
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(
                          Icons.my_location_outlined,
                          color: Colors.white,
                        ),
                        Text(
                          "Localização do Impacto",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )),
              Padding(
                padding: EdgeInsets.all(30),
                // ignore: deprecated_member_use
                child: ElevatedButton(
                  onPressed: () {
                    _salvar();
                    _showToast(context);
                    Navigator.pop(context,
                        MaterialPageRoute(builder: (context) => Home()));
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.white))),
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  child: Text(
                    "Salvar",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.zero,
                  child: GestureDetector(
                    onTap: () {
                      SystemNavigator.pop();
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                )
              ])),
    );
  }
}
