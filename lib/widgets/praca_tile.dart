import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lapis_lazuli/model/praca_pedagio.dart';
import 'package:lapis_lazuli/widgets/string_util.js.dart';

class PracaTile extends StatelessWidget {
  final PracaPedagio praca;

  PracaTile(this.praca);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 2 + 60;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildAttachment(),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 8.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: width,
                      child: Text(
                        praca.concessionaria,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Divider(
                      height: 5,
                      color: Colors.grey,
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: width,
                          child: Text(
                            "${praca.nomePraca}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: <Widget>[
                        Text(
                          "KM: ${praca.kmM}",
                          style: TextStyle(fontSize: 12.0),
                        ),
                        Text(
                          " - ${praca.uf}",
                          style: TextStyle(fontSize: 12.0),
                        ),

                      ],
                    ),
                    Text(
                      "Telefone: ${StringUtil.formatarTelefone(praca.telefone)}",
                      style: TextStyle(fontSize: 12.0),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachment() {
    DecorationImage decorationImage = DecorationImage(
      image: AssetImage("assets/pedagio.png"),
      fit: BoxFit.fill,
    );

    return Container(
      width: 80.0,
      height: 80.0,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        image: decorationImage,
        color: Colors.transparent,
      ),
    );
  }
}
