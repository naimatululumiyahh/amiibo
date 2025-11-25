import 'dart:convert';
import '../models/amiibo.dart';
import 'package:http/http.dart' as http;

 class ApiService{
  static const String _baseUrl = "https://www.amiiboapi.com/api/amiibo";
  
  static Future<List<Amiibo>> getAllAmiibo() async{
    try{
      final response = await http.get(Uri.parse(_baseUrl));
      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        List<Amiibo> amiibos = [];

        for(var item in data['amiibo']){
          amiibos.add(Amiibo.fromJson(item));
        }
        return amiibos;
      } else {
        throw Exception("Gagal Load Data");
      }
    } catch(e){
      throw Exception("Gagal Load Data: $e");
    }
  }
 }