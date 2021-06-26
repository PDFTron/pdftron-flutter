/// A convenience wrapper for building Flutter apps with PDFTron mobile SDK.
library pdftron;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'options.dart';
part 'document_view.dart';
part 'events.dart';
part 'config.dart';
part 'constants.dart';

/// A native plugin for viewing documents and accessing features of the PDFTron SDK.
class PdftronFlutter {
  static const MethodChannel _channel = const MethodChannel('pdftron_flutter');

  /// The current version of the PDFTron SDK.
  static Future<String> get platformVersion async {
    final String version =
        await _channel.invokeMethod(Functions.getPlatformVersion);
    return version;
  }

  /// The current version of the OS that the app is running on.
  static Future<String> get version async {
    final String version = await _channel.invokeMethod(Functions.getVersion);
    return version;
  }

  /// Initializes the PDFTron SDK using a license key.
  ///
  /// To run in demo mode, pass an empty string to [licenseKey]. This function must
  /// be called before opening any document, whether using [PdftronFlutter] or [DocumentView].
  static Future<void> initialize(String licenseKey) {
    return _channel.invokeMethod(Functions.initialize,
        <String, dynamic>{Parameters.licenseKey: licenseKey});
  }

  /// Opens a document in the viewer with configurations.
  ///
  /// Uses the path specified by [document]. Takes a [password] for
  /// encrypted documents, and viewer configuration options for customization.
  static Future<void> openDocument(String document,
      {String? password, Config? config}) {
    return _channel.invokeMethod(Functions.openDocument, <String, dynamic>{
      Parameters.document: document,
      Parameters.password: password,
      Parameters.config: jsonEncode(config)
    });
  }

  /// Imports XFDF annotation string to current document.
  static Future<void> importAnnotations(String xfdf) {
    return _channel.invokeMethod(
        Functions.importAnnotations, <String, dynamic>{Parameters.xfdf: xfdf});
  }

  /// Extracts XFDF annotation string from the current document.
  ///
  /// If [annotationList] is null, export all annotations from
  /// the document; else export the valid ones specified.
  static Future<String?> exportAnnotations(List<Annot>? annotationList) async {
    if (annotationList == null) {
      return _channel.invokeMethod(Functions.exportAnnotations);
    } else {
      return _channel.invokeMethod(
          Functions.exportAnnotations, <String, dynamic>{
        Parameters.annotations: jsonEncode(annotationList)
      });
    }
  }

  /// Flattens the forms and (optionally) annotations in the current document.
  static Future<void> flattenAnnotations(bool formsOnly) {
    return _channel.invokeMethod(Functions.flattenAnnotations,
        <String, dynamic>{Parameters.formsOnly: formsOnly});
  }

  /// Deletes the specified annotations in the current document.
  static Future<void> deleteAnnotations(List<Annot> annotationList) {
    return _channel.invokeMethod(Functions.deleteAnnotations,
        <String, dynamic>{Parameters.annotations: jsonEncode(annotationList)});
  }

  /// Selects the specified annotation in the current document.
  static Future<void> selectAnnotation(Annot annotation) {
    return _channel.invokeMethod(Functions.selectAnnotation,
        <String, dynamic>{Parameters.annotation: jsonEncode(annotation)});
  }

  /// Sets flags for specified annotations in the current document.
  static Future<void> setFlagsForAnnotations(
      List<AnnotWithFlag> annotationWithFlagsList) {
    return _channel.invokeMethod(
        Functions.setFlagsForAnnotations, <String, dynamic>{
      Parameters.annotationsWithFlags: jsonEncode(annotationWithFlagsList)
    });
  }

  /// Sets properties for specified annotation in the current document.
  static Future<void> setPropertiesForAnnotation(
      Annot annotation, AnnotProperty property) {
    return _channel
        .invokeMethod(Functions.setPropertiesForAnnotation, <String, dynamic>{
      Parameters.annotation: jsonEncode(annotation),
      Parameters.annotationProperties: jsonEncode(property),
    });
  }

  /// Imports remote annotation command to local document.
  ///
  /// The XFDF needs to be in a valid command format with `<add>`
  /// `<modify>` `<delete>` tags.
  static Future<void> importAnnotationCommand(String xfdfCommand) {
    return _channel.invokeMethod(Functions.importAnnotationCommand,
        <String, dynamic>{Parameters.xfdfCommand: xfdfCommand});
  }

  /// Imports user bookmarks into the document.
  ///
  /// The input needs to be in valid bookmark JSON format, for
  /// example {"0": "Page 1"}. Page numbers are 1-indexed.
  static Future<void> importBookmarkJson(String bookmarkJson) {
    return _channel.invokeMethod(Functions.importBookmarkJson,
        <String, dynamic>{Parameters.bookmarkJson: bookmarkJson});
  }

  /// Saves the currently opened document in the viewer.
  ///
  /// Also gets the absolute path to the document. Must only
  /// be called when the document is opened in the viewer.
  static Future<String?> saveDocument() {
    return _channel.invokeMethod(Functions.saveDocument);
  }

  /// Commits the current tool.
  ///
  /// Returns true for multi-stroke ink ([Tools.annotationCreateFreeHand]) and
  /// poly-shape ([Tools.annotationCreatePolygon]).
  static Future<bool?> commitTool() {
    return _channel.invokeMethod(Functions.commitTool);
  }

  /// Gets the total number of pages in the currently displayed document.
  static Future<int?> getPageCount() {
    return _channel.invokeMethod(Functions.getPageCount);
  }

  /// Handles the back button in search mode.
  ///
  /// Android only.
  static Future<bool?> handleBackButton() {
    return _channel.invokeMethod(Functions.handleBackButton);
  }

  /// Gets a map object of the crop box for the specified page.
  ///
  /// The specified page number is 1-indexed.
  static Future<Rect> getPageCropBox(int pageNumber) async {
    String cropBoxString = await _channel.invokeMethod(Functions.getPageCropBox,
        <String, dynamic>{Parameters.pageNumber: pageNumber});
    return Rect.fromJson(jsonDecode(cropBoxString));
  }

  /// Gets the rotation value of the specified page in the current document.
  ///
  /// The specified page number is 1-indexed.
  static Future<int> getPageRotation(int pageNumber) async {
    int pageRotation = await _channel.invokeMethod(Functions.getPageRotation,
        <String, dynamic>{Parameters.pageNumber: pageNumber});
    return pageRotation;
  }

  /// Sets current page of the document.
  ///
  /// The specified page number is 1-indexed.
  static Future<bool?> setCurrentPage(int pageNumber) {
    return _channel.invokeMethod(Functions.setCurrentPage,
        <String, dynamic>{Parameters.pageNumber: pageNumber});
  }

  /// Returns the path of the current document.
  static Future<String?> getDocumentPath() {
    return _channel.invokeMethod(Functions.getDocumentPath);
  }

  /// Sets the current tool mode.
  ///
  /// Takes a [Tools] string constant representing the tool mode to set.
  static Future<void> setToolMode(String toolMode) {
    return _channel.invokeMethod(Functions.setToolMode,
        <String, dynamic>{Parameters.toolMode: toolMode});
  }

  /// Sets a field flag value on one or more form fields.
  ///
  /// The [flag] is one of the constants from [FieldFlags].
  static Future<void> setFlagForFields(
      List<String> fieldNames, int flag, bool flagValue) {
    return _channel.invokeMethod(Functions.setFlagForFields, <String, dynamic>{
      Parameters.fieldNames: fieldNames,
      Parameters.flag: flag,
      Parameters.flagValue: flagValue
    });
  }

  /// Sets field values on one or more form fields of different types.
  ///
  /// Each field in [fields] list must be set with a name and a value.
  /// The value's type can be number, bool or string.
  static Future<void> setValuesForFields(List<Field> fields) {
    return _channel.invokeMethod(Functions.setValuesForFields,
        <String, dynamic>{Parameters.fields: jsonEncode(fields)});
  }

  /// Sets the file name of the icon to be used for the leading navigation button.
  ///
  /// The button will use the specified icon if [Config.showLeadingNavButton] (which by
  /// default is true) is true in the config. To add the image file to your
  /// application, please follow the steps in the
  /// [API page](https://github.com/PDFTron/pdftron-flutter/blob/publish-prep-nullsafe/doc/api/API.md#viewer-ui-configuration).
  static Future<void> setLeadingNavButtonIcon(String path) {
    return _channel.invokeMethod(Functions.setLeadingNavButtonIcon,
        <String, dynamic>{Parameters.leadingNavButtonIcon: path});
  }

  /// Closes all documents that are currently opened in a multiTab environment.
  ///
  /// A multiTab environment exists when [Config.multiTabEnabled]
  /// is true in the config.
  static Future<void> closeAllTabs() {
    return _channel.invokeMethod(Functions.closeAllTabs);
  }

  /// Deletes all annotations in the current document, excluding links and widgets.
  static Future<void> deleteAllAnnotations() {
    return _channel.invokeMethod(Functions.deleteAllAnnotations);
  }
}
