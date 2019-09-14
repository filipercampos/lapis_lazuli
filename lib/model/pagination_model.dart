import 'package:flutter/material.dart';

class PaginationModel {
  int numPage;
  int numRows;
  int totalPage;

  PaginationModel.pagination({@required this.numPage, @required this.numRows});

  PaginationModel._pagination({this.numPage, this.numRows, this.totalPage});

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    var data = json["data"];

    if (!data.containsKey("numPage") ||
        !data.containsKey("numRows") ||
        !data.containsKey("totalPages")) {
      return null;
    }

    return PaginationModel._pagination(
      numPage: data["numPage"],
      numRows: data["numRows"],
      totalPage: data["totalPages"],
    );
  }

  @override
  String toString() {
    if (numPage != null && numPage > 0 && numRows != null && numRows > 0) {
      return '?numeroPagina=$numPage&linhasPagina=$numRows';
    }
    return "";
  }
}
