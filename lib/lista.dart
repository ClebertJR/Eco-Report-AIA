import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:impactos_ambientais/model/Registro.dart';
import 'package:path_provider/path_provider.dart';
import 'helpers/RegistroHelper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home.dart';

class Lista extends StatefulWidget {
  const Lista({Key? key}) : super(key: key);

  @override
  _ListaState createState() => _ListaState();
}

class _ListaState extends State<Lista> {
  //Função para recuperar registros do banco
  RegistroHelper _db = RegistroHelper();
  List<Registro> registros = <Registro>[];
  void recuperarRegistros() async {
    List registrosRecuperados = await _db.listarRegistro();
    List<Registro>? listaTemporaria = <Registro>[];
    for (var item in registrosRecuperados) {
      Registro c = Registro.fromMapToModel(item);
      listaTemporaria.add(c);
    }
    setState(() {
      registros = listaTemporaria!;
    });

    listaTemporaria = null;
    print("Registros salvos no Banco: " + registrosRecuperados.toString());
  }

  //CSV
  List<List<dynamic>> rows = [];
  gerarCsv() async {
    List registrosRecuperados = await _db.listarRegistroCsv();

    for (var i in registrosRecuperados) {
      List<dynamic> row = [];
      row.add("Id: ${i['id']}");
      row.add("Tipo de Impacto: ${i['impacto']}");
      row.add("Observações: ${i['observacao']}");
      row.add("Localização do Impacto: ${i['localizacao']}");
      row.add("Data do Registro: ${_formatarData(i['data'])}");
      rows.add(row);
    }
    escrever();
  }

  escrever() async {
    if (await Permission.storage.request().isGranted) {
      String dir =
          (await getExternalStorageDirectory())!.path + "/relatorio.csv";
      String file = "$dir";

      File f = new File(file);

      String csv = const ListToCsvConverter().convert(rows);
      f.writeAsString(csv);
    } else {
      // ignore: unused_local_variable
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
    _showToast(context);
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text(
          'Relatório gerado com sucesso',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    recuperarRegistros();
  }

  //Função que edita registros
  void _editar({Registro? opcao}) async {
    opcao!.impacto = dropdownValue;
    opcao.observacao = descricaoController.text;

    int resultado = await _db.alterarRegistro(opcao);
    // ignore: unnecessary_null_comparison
    if (resultado != null) {
      print("Edição realizada com sucessso " + resultado.toString());
    } else {
      print("Erro ao editar!");
    }
    recuperarRegistros();
  }

  //Função excluir
  void _excluir(int id) async {
    int resultado = await _db.excluirRegistro(id);
    print("Registro $resultado Excluido");
    recuperarRegistros();
  }

  //Excluir Todos
  void _excluirTodosRegistros() async {
    int resultado = await _db.excluirTodos();
    print("Registro $resultado Excluido");
    recuperarRegistros();
  }

  //Dialogo Excluir Registro
  void exibirTelaConfirma(int id) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Excluir Registro"),
            content: Text("Você tem certeza que deseja excluir?"),
            backgroundColor: Colors.white,
            actions: <Widget>[
              // ignore: deprecated_member_use
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.white))),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.deepPurple)),
                child: Text(
                  "Cancelar",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _excluir(id);
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.white))),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.deepPurple)),
                child: Text(
                  "Confirmar",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  //Função que retorna caixa de edição de impactos.
  String dropdownValue = 'Selecione um Impacto';
  TextEditingController descricaoController = TextEditingController();

  exibirTelaEdicao(Registro registro) {
    dropdownValue = registro.impacto!;
    descricaoController.text = registro.observacao!;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Editar Informações"),
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
                          MaterialStateProperty.all(Colors.deepPurple)),
                  child: Text(
                    "Cancelar",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  )),
              ElevatedButton(
                  onPressed: () {
                    _editar(opcao: registro);
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
                    "Salvar Edição",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ))
            ],
          );
        });
  }

  //Função para formatar data
  _formatarData(data) {
    initializeDateFormatting("pt_BR");
    var formatador = DateFormat.yMEd("pt_BR");
    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;
  }

  //Confirmação deletar todos
  void exibirTodosConfirma() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Excluir Todos os Registros"),
            content:
                Text("Você tem certeza que deseja excluir todos os registros?"),
            backgroundColor: Colors.white,
            actions: <Widget>[
              // ignore: deprecated_member_use
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.white))),
                  backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                ),
                child: Text(
                  "Cancelar",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _excluirTodosRegistros();
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.white))),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.deepPurple)),
                child: Text(
                  "Confirmar",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ],
          );
        });
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
          title: Text("Registros Salvos"),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/assets/backgroundLista.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                  child: ListView.builder(
                      itemCount: registros.length,
                      itemBuilder: (context, index) {
                        final obj = registros[index];

                        return Card(
                          color: Colors.grey.withOpacity(0.5),
                          child: ListTile(
                            title: Text(
                              "Registro ${obj.id} - ${obj.impacto}",
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "Observações: ${obj.observacao} - ${_formatarData(obj.data)}",
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    exibirTelaEdicao(obj);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    exibirTelaConfirma(obj.id!);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 0),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }))
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            color: Colors.black,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        SystemNavigator.pop();
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () {
                        exibirTodosConfirma();
                      },
                      child: Icon(
                        Icons.delete_sweep,
                        color: Colors.white,
                      ),
                    ),
                  )
                ])),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await gerarCsv();
            Navigator.pop(
                context, MaterialPageRoute(builder: (context) => Home()));
          },
          child: Icon(Icons.download),
          backgroundColor: Colors.purple,
        ));
  }
}
