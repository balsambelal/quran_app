import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class search extends SearchDelegate<String>{
  String get searchFieldLabel => 'Search for a word in the Quran';

  List<String> allWords=[];
  List<String> allSuggestionWord=[];
  search(this.allWords,this.allSuggestionWord);
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: (){query = '';}, icon: Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(onPressed: (){
      close(context, query);
    },
        icon: Icon(Icons.arrow_back_ios));
  }

  @override
  Widget buildResults (BuildContext context) {
    // List<String> dummyListData = <String>[];
    // if(query.isNotEmpty) {
    //   allWords.forEach((item) {
    //     if(item.contains(query)) {
    //       dummyListData.add(item);
    //     }
    //   });
    // }
    // final List<String> allResult = allWords.where((element) => element.contains(query)).toList();
    // //final List<String> allResult=[];
    // print(query);
    // for (int i = 0; i < allWords.length; i++){
    //    if(allWords[i].contains(query)==0){
    //      allResult.add(allWords[i]);
    //    }
    //  }
    //  print(allResult);
    //  print(allWords);
    //  //return Text(query);
    //  return ListView.builder(itemCount: allResult.length,
    //      itemBuilder: (context,index){
    //    return ListTile(title: Text(allResult[index]),onTap:(){
    //      query=allResult[index];
    //      close(context, query);});
    //  });
    return FutureBuilder (
      future: searchForWord(query),
      builder: (context, snapshot) {
          if (snapshot.hasData ) {
            List data = snapshot!.data as List;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final verse = data[index];
                return ListTile(
                  title: Text(verse['text']),
                  subtitle: Text(
                      '${verse['surah']['name']} ${verse['surah']['number']}:${verse['numberInSurah']}'),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> allSuggestion = allSuggestionWord.where((element) => element.contains(query)).toList();
    return ListView.builder(itemCount: allSuggestion.length,
        itemBuilder: (context,index){
          return ListTile(title: Text(allSuggestion[index]),
              onTap:(){
            query=allSuggestion[index];
            close(context, query);});
        });

  }

  Future<List<dynamic>> searchForWord(String word) async {
    //final url = 'http://api.alquran.cloud/v1/search/$word/all/en.pickthall';
    final url = 'http://api.alquran.cloud/v1/search/$word/all/ar';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //final verses = data['data']['matches'][0]['verses'];
      final verses = data['data']['matches'];
      return verses;
    } else {
      throw Exception('Failed to search for word');
    }
  }


}