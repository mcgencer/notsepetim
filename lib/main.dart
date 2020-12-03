import 'package:flutter/material.dart';
import 'package:flutter_app/kategori_islemleri.dart';
import 'package:flutter_app/not_detay.dart';
import 'package:flutter_app/utils/database_helper.dart';
import 'package:flutter_app/models/kategori.dart';

import 'models/kategori.dart';
import 'dart:async';
import 'dart:io';

import 'models/notlar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Not Sepetim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Raleway',
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.deepOrangeAccent,
      ),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatefulWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  _NotListesiState createState() => _NotListesiState();
}

class _NotListesiState extends State<NotListesi> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _yeniKategori;

  Widget build(BuildContext context) {
    debugPrint("Not Build Çalıştı");
    return Scaffold(
      key: NotListesi.scaffoldKey,
      appBar: AppBar(
        title: Text("Not Sepetim"),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    child: ListTile(
                  leading: Icon(Icons.category),
                  title: Text(
                    "Kategoriler",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _kategorilerSayfasinaGit(context);
                  },
                )),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              kategoriEkleDialog(context);
            },
            tooltip: "Kategori Ekle",
            heroTag: "KategoriEkle",
            child: Icon(
              Icons.import_contacts,
              color: Colors.white,
            ),
            mini: true,
          ),
          FloatingActionButton(
            tooltip: "Not Ekle",
            heroTag: "NotEkle",
            onPressed: () {
              notEkleDialog(context);
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
      body: Notlar(),
    );
  }

  void kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String yeniKategoriAdi;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Kategori Ekle",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          children: <Widget>[
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Kategori Adı",
                    border: OutlineInputBorder(),
                  ),
                  validator: (girilenDeger) {
                    if (girilenDeger.length < 3) {
                      return "En az 3 karakter giriniz";
                    } else
                      return null;
                  },
                  onSaved: (girilenDeger) => _yeniKategori = girilenDeger,
                ),
              ),
            ),
            ButtonBar(
              children: <Widget>[
                OutlineButton(
                  borderSide:
                  BorderSide(color: Theme.of(context).primaryColor),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.orangeAccent,
                  child: Text(
                    "Vazgeç",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                OutlineButton(
                  borderSide: BorderSide(color: Theme.of(context).accentColor),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      _databaseHelper
                          .kategoriEkle(Kategori(_yeniKategori))
                          .then((kategoriID) {
                        if (kategoriID > 0) {
                          NotListesi.scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text("Kategori Eklendi"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      });
                    }
                  },
                  color: Colors.redAccent,
                  child: Text(
                    "Kaydet",
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void notEkleDialog(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                NotDetay(baslik: "Yeni Not"))).then((value) => setState(() {}));
  }

  void _kategorilerSayfasinaGit(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Kategoriler()));
  }
}

class Notlar extends StatefulWidget {
  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  List<Not> tumNotlar;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumNotlar = List<Not>();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseHelper.notListesiniGetir(),
      builder: (context, AsyncSnapshot<List<Not>> snapShot) {
        if (snapShot.connectionState == ConnectionState.done) {
          tumNotlar = snapShot.data;
          sleep(Duration(milliseconds: 500));
          return ListView.builder(
              itemCount: tumNotlar.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  leading: _oncelikIconuAta(tumNotlar[index].notOncelik),
                  title: Text(tumNotlar[index].notBaslik),
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Kategori ",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  tumNotlar[index].kategoriBaslik,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Oluşturulma Tarihi :  ",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  databaseHelper.dateFormat(DateTime.parse(
                                      tumNotlar[index].notTarih)),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "İçerik:\n\n" + tumNotlar[index].notIcerik,
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FlatButton(
                                  onPressed: () =>
                                      _notSil(tumNotlar[index].notID),
                                  child: Text("SİL",
                                      style:
                                          TextStyle(color: Colors.redAccent))),
                              FlatButton(
                                  onPressed: () {
                                    notEkleDialog(context, tumNotlar[index]);
                                  },
                                  child: Text("GÜNCELLE",
                                      style: TextStyle(color: Colors.green))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
        } else {
          return Center(child: Text("Yükleniyor..."));
        }
      },
    );
  }

  void _notSil(int notID) {
    databaseHelper.notSil(notID).then((onValue) {
      if (onValue > 0) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Not Silindi"),
            duration: Duration(seconds: 1),
          ),
        );
        setState(() {});
      }
    });
  }

  _oncelikIconuAta(int notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          child: Text(
            "AZ",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade100,
        );
        break;
      case 1:
        return CircleAvatar(
          child: Text(
            "ORTA",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade200,
        );
        break;
      case 2:
        return CircleAvatar(
          child: Text(
            "ACİL",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade700,
        );
        break;
    }
  }

  void notEkleDialog(BuildContext context, Not not) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    NotDetay(baslik: "Notu Güncelle", guncellenecekNot: not)))
        .then((value) => setState(() {}));
    setState(() {});
  }
}
