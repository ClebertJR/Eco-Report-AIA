import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:impactos_ambientais/model/Registro.dart';
import 'package:path/path.dart';

class RegistroHelper {
  //Criação Banco de dados
  recuperarBancoDados() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "banco.db");

    var bd = await openDatabase(localBancoDados, version: 1,
        onCreate: (db, dbVersaoRecente) {
      String sql =
          "CREATE TABLE checklist (id INTEGER PRIMARY KEY AUTOINCREMENT, foto VARCHAR, impacto VARCHAR, observacao VARCHAR, localizacao VARCHAR, data DATETIME)";
      db.execute(sql);
    });
    print("aberto: " + bd.isOpen.toString());
    return bd;
  }

  //CRUD

  //Create
  Future<int> inserirRegistro(Registro obj) async {
    Database db = await recuperarBancoDados(); //this.database;
    var resultado = await db.insert("checklist", obj.toMap());
    return resultado;
  }

  //Read
  listarRegistro() async {
    Database db = await recuperarBancoDados(); //this.database;
    String sql = "SELECT * FROM checklist ORDER BY data DESC";
    List listaRegistros = await db.rawQuery(sql);
    return listaRegistros;
  }

  //Read CSV
  listarRegistroCsv() async {
    Database db = await recuperarBancoDados(); //this.database;
    String sql = "SELECT * FROM checklist ORDER BY id ASC";
    List listaRegistros = await db.rawQuery(sql);
    return listaRegistros;
  }

  //Update
  Future<int> alterarRegistro(Registro obj) async {
    Database db = await recuperarBancoDados();
    var resultado = await db
        .update("checklist", obj.toMap(), where: "id = ?", whereArgs: [obj.id]);
    return resultado;
  }

  //Delete
  Future<int> excluirRegistro(int id) async {
    Database db = await recuperarBancoDados();
    var resultado =
        await db.delete("checklist", where: "id = ?", whereArgs: [id]);
    return resultado;
  }

  //Delete All
  Future<int> excluirTodos() async {
    Database db = await recuperarBancoDados();
    var resultado = await db.delete("checklist");
    return resultado;
  }
}
