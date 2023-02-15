class Registro {
  //Atributos da classe
  int? id;
  String? foto;
  String? impacto;
  String? observacao;
  String? localizacao;
  String? data;

  //Construtor da classe
  Registro(
      this.foto, this.impacto, this.observacao, this.localizacao, this.data);

  //Método de converção de objeto (model) para map
  Map<String, dynamic> toMap() {
    var dados = Map<String, dynamic>();
    dados['id'] = id;
    dados['foto'] = foto;
    dados['impacto'] = impacto;
    dados['observacao'] = observacao;
    dados['localizacao'] = localizacao;
    dados['data'] = data;

    return dados;
  }

  //Método de conversão de map para objeto (model)
  Registro.fromMapToModel(Map<String, dynamic> dados) {
    this.id = dados['id'];
    this.foto = dados['foto'];
    this.impacto = dados['impacto'];
    this.observacao = dados['observacao'];
    this.localizacao = dados['localizacao'];
    this.data = dados['data'];
  }
}
