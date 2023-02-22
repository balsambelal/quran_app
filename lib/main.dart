import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app_balsam/search.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en', 'US'), Locale('ar', 'SA')],
        path: 'assets',
        fallbackLocale: Locale('en', 'US'),
        child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Quran App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int currentPage = 1;
  bool isLoading = false;
  dynamic data;

  late PageController pageController;

  getData(int page) async {
    data = [];
    http.Response response = await http.get(
      Uri.parse('http://api.alquran.cloud/v1/page/$page/quran-uthmani'),
    );

    var result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        isLoading = true;
        data = result['data']['ayahs'] as List;
      });
    }
    return null;
  }

//   getAyas(){
//     setState(() {
//       for (int i = 0; i < data.length; i++){
//         String ayas = data[i]['text'];
//         allWords.add(ayas);
//       }
//     });
//    // print('the ayes $allWords)');
// }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 1);
    getData(currentPage);
   //getAyas();
  }
  String selectedword='';
  List<String> allSuggestion=[];
  List<String> allWords=[];

  @override
  Widget build(BuildContext context) {
    //getAyas();
    return Scaffold(
        backgroundColor: Colors.brown[100],
        appBar: AppBar(title: Text('Quran App'),actions: [IconButton(onPressed: ()async{
    final finalresult = await showSearch(
    context: context, delegate: search(allWords,allSuggestion));
    setState(() {
    selectedword = finalresult!;
    });
    }, icon: Icon(Icons.search))],),
      body: SafeArea(
        child: Column(
          children: [
            // OutlinedButton.icon(
            //   label: Text('Search'),
            //   icon: Icon(Icons.search),
            //   style: OutlinedButton.styleFrom(
            //     side: BorderSide(color: Colors.blue),
            //   ),
            //   onPressed: ()async{
            //       final finalresult = await showSearch(
            //           context: context, delegate: search(allWords,allSuggestion));
            //   setState(() {
            //     selectedword = finalresult!;
            //   });
            //       },
            // ),
            // selectedword == ''?Container():Container(
            //   padding: EdgeInsets.symmetric(vertical: 15,horizontal: 35),
            //   color: Colors.deepOrange,
            //   child: Text(selectedword,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
            // ),
            // Expanded(child: ListView.builder(itemBuilder: (context,index){
            //   return ListTile(
            //     title: Text(allwords[index]),
            //   );
            // },itemCount: allwords.length,)),
            Expanded(
              child: Center(
                child: !isLoading
                    ? CircularProgressIndicator()
                    : SafeArea(
                        child: PageView.builder(
                          itemCount: 604,
                          controller: pageController,
                          onPageChanged: (page) {
                            setState(() {
                              currentPage = page;
                              getData(page);
                            });
                          },
                          itemBuilder: (BuildContext context, int index) {
                            if (index == currentPage && data.length != 0) {

                              for (int i = 0; i < data.length; i++){
                                allWords.add(data[i]['text']);
                              }

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.justify,
                                  locale: context.locale,
                                  text: TextSpan(
                                      text: '',
                                      recognizer: DoubleTapGestureRecognizer()
                                        ..onDoubleTap = () {
                                          setState(() {});
                                        },
                                      style: TextStyle(
                                        fontFamily: 'Kitab',
                                        // fontFamily: 'HafsSmart',
                                        color: Colors.black,
                                        fontSize: 24,
                                        // height: 2,
                                        textBaseline: TextBaseline.alphabetic,
                                      ),
                                      children: [
                                        for (int i = 0; i < data.length; i++) ...{
                                          TextSpan(
                                            text: '${data[i]['text']}',
                                          ),
                                          WidgetSpan(
                                            baseline: TextBaseline.alphabetic,
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 8),
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  opacity: 0.5,
                                                  image: AssetImage(
                                                    'images/end.png',
                                                  ),
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child:
                                                  Text('${data[i]['numberInSurah']}'),
                                            ),
                                          ),
                                        }
                                      ]),
                                ),
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
