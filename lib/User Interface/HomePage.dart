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

  //Caso queira implementar navegação entre as páginas.
  int _page = 1;

  //Retorna no futuro.
  Future<Map> _getSearch() async {
    http.Response response;

    //async e await, pois deve esperar uma resposta do servidor, caso tente pegar instântaneamente dará erro.
    if (_search == null || _search.isEmpty)
      response = await http.get(

          //Caso o campo de busca não esteja preenchido, irá exibir o trending topweek.
          "https://api.themoviedb.org/3/trending/movie/week?api_key=0076a65c36aca0c774d36dcc20366abf");
    else
      response = await http.get(
          //Caso o campo de busca seja preenchido, irá pegar a API já configurada.
          "https://api.themoviedb.org/3/search/movie?api_key=0076a65c36aca0c774d36dcc20366abf&language=pt-BR&query=$_search&page=$_page&include_adult=false");

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Busca TMDB"),
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
                        color: Colors.white),
                    border: OutlineInputBorder()),
                style: TextStyle(color: Colors.white, fontSize: 18.0),
                textAlign: TextAlign.center,
                //onSumitted para pesquisar apenas depois de clicar no "ok"
                onSubmitted: (text){
                    //setState para atualizar a lista de filmes quando envia o texto.
                   setState(() {
                     _search = text;
                   });
                },
              ),
            ),
            //Um expanded para preencer toda a tela.
            Expanded(
              //caso demore para obter os dados da API, colocamos um Futurebuilder.
              child: FutureBuilder(
                future: _getSearch(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    //verifica o estado e a partir disso retorna algo.
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      //Caso dê errado, irá carregar uma animação de carregamento.
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
        padding: EdgeInsets.all(5.0), //UX
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        // quantidade de itens no array de resultados
        itemCount: snapshot.data["results"].length,
        //passar uma função que vai retornar o widget de cada posição
        itemBuilder: (context, index){
          //Para ser capaz de clicar na imagem para ver os detalhes.
          return GestureDetector(
            child:
              //Faz a requisição na API do cartaz de cada filme, sendo necessário concatenar com o restante do link.
              Image.network("https://image.tmdb.org/t/p/w500" + (snapshot.data["results"][index]["poster_path"])),
            onTap: (){
              Navigator.push(context,
                //Criaçã da função para navegação entre telas.
                MaterialPageRoute(builder: (context) => Movie_details(snapshot.data["results"][index]))
              );
            },
          );
        } );


  }
}
