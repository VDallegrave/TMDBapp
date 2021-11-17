import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'HomePage.dart';
import 'package:url_launcher/url_launcher.dart';

//não irá ter interação com a página


class Movie_details extends StatelessWidget {

  final Map _movieData;
//  var _movieID;

  //construtor para passar dados do filme que iremos mostrar
  Movie_details(this._movieData);

  //Retorna no futuro.
  Future<Map> getDetails() async {
    //Salva o id na variável que poderá ser usada na requisição da api
    var _movieID = _movieData["id"];

    http.Response response;
    //async e await, pois deve esperar uma resposta do servidor, caso tente pegar instântaneamente dará erro.
    response = await http.get("https://api.themoviedb.org/3/movie/$_movieID?api_key=0076a65c36aca0c774d36dcc20366abf&language=pt-BR");

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          title: Text(_movieData["original_title"]),
          centerTitle: true,
        ),
        backgroundColor: Colors.black,
        body: FutureBuilder(
          future: getDetails(),
          builder: (contex, snapshot){
            switch(snapshot.connectionState){
              //verifica o estado e a partir disso retorna algo.
              case ConnectionState.none:
              case ConnectionState.waiting:
              return Center(child: Text("Carregando"));
              default:
                if(snapshot.hasError){
                  return Center(child: Text("Erro") ,);
                }
                else {
                  //SingleScrollView para permitir rolagem caso as informações passe da tela
                  return SingleChildScrollView(

                    //Padding para melhora a visualização
                    padding: EdgeInsets.all(10.0),
                    //Coluna com todas os detalhes que queira inserir.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Image.network("https://image.tmdb.org/t/p/w500" + (snapshot.data["poster_path"]), height: 350,),
                        Divider(),
                        Text("Descrição: " + (snapshot.data["overview"]),
                          style: TextStyle(color: Colors.white, fontSize: 20.0),),
                        Divider(),
                        Text("Idioma Original: " + (snapshot.data["original_language"]),
                          style: TextStyle(color: Colors.white, fontSize: 20.0),),
                        Divider(),
                        Text("Popularidade: " + (snapshot.data["popularity"]).toStringAsFixed(0),
                          style: TextStyle(color: Colors.white, fontSize: 20.0),),
                        Divider(),
                        Text("Nota: " + (snapshot.data["vote_average"]).toStringAsFixed(1),
                          style: TextStyle(color: Colors.white, fontSize: 20.0),),
                      ],
                    ),
                  );
                }
            }
          }
        )
    );
  }
}

