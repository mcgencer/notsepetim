import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/kategori.dart';
import 'package:flutter_app/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'models/notlar.dart';

class NotDetay extends StatefulWidget {
  String baslik;
  Not guncellenecekNot;

  NotDetay({this.baslik, this.guncellenecekNot});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  var formKey = GlobalKey<FormState>();
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;
  int kategoriID ;
  int secilenOncelik;
  String notBaslik, notIcerik;

  static var _oncelik = ["Düşük", "Orta", "Yüksek"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumKategoriler = List<Kategori>();
    databaseHelper = DatabaseHelper();
    databaseHelper.kategorileriGetir().then((kategoriIcerenMapListesi) {
      for (Map okunanMap in kategoriIcerenMapListesi) {
        tumKategoriler.add(Kategori.fromMap(okunanMap));
      }
      if(widget.guncellenecekNot != null){
        kategoriID= widget.guncellenecekNot.kategoriID;
        secilenOncelik=widget.guncellenecekNot.notOncelik;
      }else{
        kategoriID=1;
        secilenOncelik=0;
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.baslik),
      ),
      body: tumKategoriler.length <= 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Kategori: ",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.deepPurpleAccent, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                  items: kategoriItemleriOlustur(),
                                  value:kategoriID,
                                  onChanged: (secilenKategoriID) {
                                    setState(() {
                                      kategoriID = secilenKategoriID;
                                    });
                                  })),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: widget.guncellenecekNot != null
                            ? widget.guncellenecekNot.notBaslik
                            : "",
                        validator: (text) {
                          if (text.length < 3) {
                            return "En Az 3 Karakter Olmalı";
                          }
                        },
                        onSaved: (text) {
                          notBaslik = text;
                        },
                        decoration: InputDecoration(
                          hintText: "Not Başlığını Giriniz",
                          labelText: "Başlık",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: widget.guncellenecekNot != null
                            ? widget.guncellenecekNot.notIcerik
                            : "",
                        onSaved: (text) {
                          notIcerik = text;
                        },
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Not İçeriğini Giriniz",
                          labelText: "İçerik",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Öncelik: ",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.deepPurpleAccent, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                  items: _oncelik.map((oncelik) {
                                    return DropdownMenuItem<int>(
                                      child: Text(
                                        oncelik,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      value: _oncelik.indexOf(oncelik),
                                    );
                                  }).toList(),
                                  value: secilenOncelik,
                                  onChanged: (secilenOncelikID) {
                                    setState(() {
                                      secilenOncelik = secilenOncelikID;
                                    });
                                  })),
                        ),
                      ],
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Vazgeç"),
                          color: Colors.grey.shade400,
                        ),
                        RaisedButton(
                          onPressed: () {
                            if (formKey.currentState.validate()) {
                              formKey.currentState.save();

                              var suan = DateTime.now();
                              if (widget.guncellenecekNot == null) {
                                databaseHelper
                                    .notEkle(Not(
                                        kategoriID,
                                        notBaslik,
                                        notIcerik,
                                        suan.toString(),
                                        secilenOncelik))
                                    .then((kaydedilenNotID) {
                                  if (kaydedilenNotID != 0) {
                                    Navigator.pop(context);
                                  }
                                });
                              } else {
                                databaseHelper.notGuncelle(Not.withID(
                                        widget.guncellenecekNot.notID,
                                        kategoriID,
                                        notBaslik,
                                        notIcerik,
                                        suan.toString(),
                                        secilenOncelik)).then((guncellenenID) {
                                          if(guncellenenID !=0){
                                            Navigator.pop(context);
                                          }

                                });
                              }
                            }
                          },
                          child: Text(
                            "Kaydet",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.redAccent.shade700,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  List<DropdownMenuItem<int>> kategoriItemleriOlustur() {
    return tumKategoriler
        .map((kategori) => DropdownMenuItem<int>(
              value: kategori.kategoriID,
              child: Text(
                kategori.kategoriBaslik,
                style: TextStyle(fontSize: 20),
              ),
            ))
        .toList();
  }
}

