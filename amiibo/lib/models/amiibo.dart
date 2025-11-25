class Amiibo {
  final String amiiboSeries;
  final String character;
  final String gameSeries;
  final String head;
  final String image;
  final String name;
  final String releaseau;
  final String releaseeu;
  final String releasejp;
  final String releasena;
  final String tail;
  final String type;


  Amiibo({
    required this.amiiboSeries,
    required this.character,
    required this.gameSeries,
    required this.head,
    required this.image,
    required this.name,
    required this.releaseau,
    required this.releaseeu,
    required this.releasejp,
    required this.releasena,
    required this.tail,
    required this.type,
  });



  factory Amiibo.fromJson(Map<String, dynamic> json){
    return Amiibo(
      amiiboSeries: json['amiiboSeries'],
      character: json['character'],
      gameSeries: json['gameSeries'],
      head: json['head'],
      image: json['image'],
      name: json['name'],
      releaseau: json['release']['au'].toString(),
      releaseeu: json['release']['eu'].toString(),
      releasejp: json['release']['jp'].toString(),
      releasena: json['release']['na'].toString(),
      tail: json['tail'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amiiboSeries': amiiboSeries,
      'character': character,
      'gameSeries': gameSeries,
      'head': head,
      'image': image,
      'name': name,
      'releaseau': releaseau,
      'releaseeu': releaseeu,
      'releasejp': releasejp,
      'releasena': releasena,
      'tail': tail,
      'type': type,
    };
  }
}