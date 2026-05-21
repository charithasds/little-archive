import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/book_fair_event_model.dart';

part 'book_fair_local_datasource.g.dart';

abstract class BookFairLocalDataSource {
  Future<BookFairEventModel> getBookFairEvent();
}

class BookFairLocalDataSourceImpl implements BookFairLocalDataSource {
  @override
  Future<BookFairEventModel> getBookFairEvent() async {
    final String jsonString = await rootBundle.loadString('assets/book_fair/cibf_stalls.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    return BookFairEventModel.fromJson(jsonMap);
  }
}

@riverpod
BookFairLocalDataSource bookFairLocalDataSource(Ref ref) => BookFairLocalDataSourceImpl();
