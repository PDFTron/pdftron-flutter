library pdftron;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

part 'options.dart';
part 'document_view.dart';
part 'events.dart';
part 'config.dart';
part 'constants.dart';

class PdftronFlutter {
  static const MethodChannel _channel = const MethodChannel('pdftron_flutter');

  static Future<String> get platformVersion async {
    final String version =
        await _channel.invokeMethod(Functions.getPlatformVersion);
    return version;
  }

  static Future<String> get version async {
    final String version = await _channel.invokeMethod(Functions.getVersion);
    return version;
  }

  static Future<void> initialize([String licenseKey = ""]) {
    return _channel.invokeMethod(Functions.initialize,
        <String, dynamic>{Parameters.licenseKey: licenseKey});
  }

  static Future<void> openDocument(String document,
      {String password, Config config}) {
    return _channel.invokeMethod(Functions.openDocument, <String, dynamic>{
      Parameters.document: document,
      Parameters.password: password,
      Parameters.config: jsonEncode(config)
    });
  }

  static Future<void> importAnnotations(String xfdf) {
    return _channel.invokeMethod(
        Functions.importAnnotations, <String, dynamic>{Parameters.xfdf: xfdf});
  }

  static Future<String> exportAnnotations(List<Annot> annotationList) async {
    if (annotationList == null) {
      return _channel.invokeMethod(Functions.exportAnnotations);
    } else {
      return _channel.invokeMethod(
          Functions.exportAnnotations, <String, dynamic>{
        Parameters.annotations: jsonEncode(annotationList)
      });
    }
  }

  static Future<void> flattenAnnotations(bool formsOnly) {
    return _channel.invokeMethod(Functions.flattenAnnotations,
        <String, dynamic>{Parameters.formsOnly: formsOnly});
  }

  static Future<void> deleteAnnotations(List<Annot> annotationList) {
    return _channel.invokeMethod(Functions.deleteAnnotations,
        <String, dynamic>{Parameters.annotations: jsonEncode(annotationList)});
  }

  static Future<void> selectAnnotation(Annot annotation) {
    return _channel.invokeMethod(Functions.selectAnnotation,
        <String, dynamic>{Parameters.annotation: jsonEncode(annotation)});
  }

  static Future<void> setFlagsForAnnotations(
      List<AnnotWithFlag> annotationWithFlagsList) {
    return _channel.invokeMethod(
        Functions.setFlagsForAnnotations, <String, dynamic>{
      Parameters.annotationsWithFlags: jsonEncode(annotationWithFlagsList)
    });
  }

  static Future<void> setPropertiesForAnnotation(
      Annot annotation, AnnotProperty property) {
    return _channel
        .invokeMethod(Functions.setPropertiesForAnnotation, <String, dynamic>{
      Parameters.annotation: jsonEncode(annotation),
      Parameters.annotationProperties: jsonEncode(property),
    });
  }

  static Future<void> groupAnnotations(Annot primaryAnnotation, List<Annot> subAnnotations) {
    return _channel.invokeMethod(Functions.groupAnnotations,
        <String, dynamic>{
        Parameters.annotation: jsonEncode(primaryAnnotation),
        Parameters.annotations: jsonEncode(subAnnotations)
        });
  }

  static Future<void> ungroupAnnotations(List<Annot> annotations) {
    return _channel.invokeMethod(Functions.ungroupAnnotations,
        <String, dynamic>{
        Parameters.annotations: jsonEncode(annotations)
        });
  }

  static Future<void> importAnnotationCommand(String xfdfCommand) {
    return _channel.invokeMethod(Functions.importAnnotationCommand,
        <String, dynamic>{Parameters.xfdfCommand: xfdfCommand});
  }

  static Future<void> importBookmarkJson(String bookmarkJson) {
    return _channel.invokeMethod(Functions.importBookmarkJson,
        <String, dynamic>{Parameters.bookmarkJson: bookmarkJson});
  }

  static Future<void> addBookmark(String title, int pageNumber) {
    return _channel
        .invokeMethod(Functions.addBookmark, <String, dynamic>{
      Parameters.title: title,
      Parameters.pageNumber: pageNumber
    });
  }

  static Future<String> saveDocument() {
    return _channel.invokeMethod(Functions.saveDocument);
  }

  static Future<bool> commitTool() {
    return _channel.invokeMethod(Functions.commitTool);
  }

  static Future<int> getPageCount() {
    return _channel.invokeMethod(Functions.getPageCount);
  }

  static Future<bool> handleBackButton() {
    return _channel.invokeMethod(Functions.handleBackButton);
  }

  static Future<void> undo() {
    return _channel.invokeMethod(Functions.undo);
  }
  
  static Future<void> redo() {
    return _channel.invokeMethod(Functions.redo);
  }

  static Future<bool> canUndo() {
    return _channel.invokeMethod(Functions.canUndo);
  }
  
  static Future<bool> canRedo() {
    return _channel.invokeMethod(Functions.canRedo);
  }

  static Future<Rect> getPageCropBox(int pageNumber) async {
    String cropBoxString = await _channel.invokeMethod(Functions.getPageCropBox,
        <String, dynamic>{Parameters.pageNumber: pageNumber});
    return Rect.fromJson(jsonDecode(cropBoxString));
  }

  static Future<int> getPageRotation(int pageNumber) async {
    int pageRotation = await _channel.invokeMethod(Functions.getPageRotation,
        <String, dynamic>{Parameters.pageNumber: pageNumber});
    return pageRotation;
  }

  static Future<void> rotateClockwise() {
    return _channel.invokeMethod(Functions.rotateClockwise);
  }

  static Future<void> rotateCounterClockwise() {
    return _channel.invokeMethod(Functions.rotateCounterClockwise);
  }

  static Future<bool> setCurrentPage(int pageNumber) {
    return _channel.invokeMethod(Functions.setCurrentPage,
        <String, dynamic>{Parameters.pageNumber: pageNumber});
  }

  static Future<String> getDocumentPath() {
    return _channel.invokeMethod(Functions.getDocumentPath);
  }

  static Future<void> setToolMode(String toolMode) {
    return _channel.invokeMethod(Functions.setToolMode,
        <String, dynamic>{Parameters.toolMode: toolMode});
  }

  static Future<void> setFlagForFields(
      List<String> fieldNames, int flag, bool flagValue) {
    return _channel.invokeMethod(Functions.setFlagForFields, <String, dynamic>{
      Parameters.fieldNames: fieldNames,
      Parameters.flag: flag,
      Parameters.flagValue: flagValue
    });
  }

  static Future<void> setValuesForFields(List<Field> fields) {
    return _channel.invokeMethod(Functions.setValuesForFields,
        <String, dynamic>{Parameters.fields: jsonEncode(fields)});
  }

  static Future<void> setLeadingNavButtonIcon(String path) {
    return _channel.invokeMethod(Functions.setLeadingNavButtonIcon,
        <String, dynamic>{Parameters.leadingNavButtonIcon: path});
  }

  static Future<void> closeAllTabs() {
    return _channel.invokeMethod(Functions.closeAllTabs);
  }
  
  static Future<void> deleteAllAnnotations() {
    return _channel.invokeMethod(Functions.deleteAllAnnotations);
  }

  static Future<String> exportAsImage(int pageNumber, int dpi, String exportFormat) {
    return _channel.invokeMethod(Functions.exportAsImage, <String, dynamic>{
      Parameters.pageNumber: pageNumber,
      Parameters.dpi: dpi,
      Parameters.exportFormat: exportFormat
    });
  }

  static Future<String> exportAsImageFromFilePath(int pageNumber, int dpi, String exportFormat, String filePath) {
    return _channel.invokeMethod(Functions.exportAsImageFromFilePath, <String, dynamic>{
      Parameters.pageNumber: pageNumber,
      Parameters.dpi: dpi,
      Parameters.exportFormat: exportFormat,
      Parameters.path: filePath
    });
  }
  
  static Future<void> openAnnotationList() {
    return _channel.invokeMethod(Functions.openAnnotationList);
  }

  static Future<void> openBookmarkList() {
    return _channel.invokeMethod(Functions.openBookmarkList);
  }

  static Future<void> openOutlineList() {
    return _channel.invokeMethod(Functions.openOutlineList);
  }

  static Future<void> openLayersList() {
    return _channel.invokeMethod(Functions.openLayersList);
  }

  static Future<void> openThumbnailsView() {
    return _channel.invokeMethod(Functions.openThumbnailsView);
  }
  
  static Future<void> openRotateDialog() {
    return _channel.invokeMethod(Functions.openRotateDialog);
  }

  static Future<void> openAddPagesView(Map<String, double> sourceRect) {
    return _channel.invokeMethod(Functions.openAddPagesView,
        <String, dynamic>{Parameters.sourceRect: sourceRect});
  }

  static Future<void> openViewSettings(Map<String, double> sourceRect) {
    return _channel.invokeMethod(Functions.openViewSettings,
        <String, dynamic>{Parameters.sourceRect: sourceRect});
  }

  static Future<void> openCrop() {
    return _channel.invokeMethod(Functions.openCrop);
  }

  static Future<void> openManualCrop() {
    return _channel.invokeMethod(Functions.openManualCrop);
  }

  static Future<void> openSearch() {
    return _channel.invokeMethod(Functions.openSearch);
  }

  static Future<void> openTabSwitcher() {
    return _channel.invokeMethod(Functions.openTabSwitcher);
  }
  
  static Future<void> openGoToPageView() {
    return _channel.invokeMethod(Functions.openGoToPageView);
  }

  static Future<void> openNavigationLists() {
    return _channel.invokeMethod(Functions.openNavigationLists);
  }

  // Android only.
  static Future<void> setRequestedOrientation(int requestedOrientation) {
    return _channel.invokeMethod(Functions.setRequestedOrientation,
        <String, dynamic>{Parameters.requestedOrientation: requestedOrientation});
  }

  static Future<bool> gotoPreviousPage() {
    return _channel.invokeMethod(Functions.gotoPreviousPage);
  }

  static Future<bool> gotoNextPage() {
    return _channel.invokeMethod(Functions.gotoNextPage);
  }

  static Future<bool> gotoFirstPage() {
    return _channel.invokeMethod(Functions.gotoFirstPage);
  }

  static Future<bool> gotoLastPage() {
    return _channel.invokeMethod(Functions.gotoLastPage);
  }

  static Future<int> getCurrentPage() {
    return _channel.invokeMethod(Functions.getCurrentPage);
  }
}
