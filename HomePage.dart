import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

import 'movie_details.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  String _search;

  int _page = 1; //Navegação entre as páginas

  Future<Map> _getSearch() async {
    //Retorna algo no futuro.
    http.Response response;

    if (_search == null || _search.isEmpty) //await pois deve esperar uma resposta do servidor, caso tente pegar instântaneamente dará erro.
      response = await http.get(
          "https://api.themoviedb.org/3/trending/movie/week?api_key=0076a65c36aca0c774d36dcc20366abf"); //Caso o campo de busca não esteja preenchido, irá exibir o trending topweek.
    else
      response = await http.get(
          "https://api.themoviedb.org/3/search/movie?api_key=0076a65c36aca0c774d36dcc20366abf&language=pt-BR&query=$_search&page=$_page&include_adult=false"); //Caso o campo de busca seja preenchido, irá pegar a API já configurada.

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getSearch().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Image.network(
              "https://www.themoviedb.org/assets/2/v4/logos/v2/blue_long_1-8ba2ac31f354005783fab473602c34c3f4fd207150182061e425d366e4f34596.svg"),
          centerTitle: true,
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "Busque pelo título",
                    labelStyle: TextStyle(
                        color: Colors.white), //tentar com cor: #01b4e4
                    border: OutlineInputBorder()),
                style: TextStyle(color: Colors.white, fontSize: 18.0),
                textAlign: TextAlign.center,
                onSubmitted: (text){
                   setState(() {  //setState para atualizar a lista de filmes
                     _search = text;

                   });
                },//pesquisar apenas depois de clicar no "ok"
              ),
            ),
            Expanded(
              //caso demore para obter os dados da API, colocamos um Futurebuilder, em expanded para preencer toda a tela.
              child: FutureBuilder(
                future: _getSearch(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    //verifica o estado e a partir disso retorna algo.
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                   default:
                     if(snapshot.hasError) return Container();
                     else {
                       return _createMovieTable(context, snapshot);

                     }}
                }
              ),
            )
          ],
        ));
  }

  Widget _createMovieTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
        padding: EdgeInsets.all(10.0), //UX
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: snapshot.data["results"].length, // quantidade de itens no array de resultados
        itemBuilder: (context, index){
          return GestureDetector( //ser capaz de clicar na imagem para ver os detalhes
            child:
              Image.network("https://image.tmdb.org/t/p/w500" + (snapshot.data["results"][index]["poster_path"])),
            onTap: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Movie_details(snapshot.data["results"][index]))
              );
            },
          );
        } ); //passar uma função que vai retornar o widget de cada posição
  }

}
