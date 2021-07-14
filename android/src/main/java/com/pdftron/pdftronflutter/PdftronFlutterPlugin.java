package com.pdftron.pdftronflutter;

import android.content.Context;

import com.pdftron.common.PDFNetException;
import com.pdftron.pdf.PDFNet;
import com.pdftron.pdftronflutter.factories.DocumentViewFactory;
import com.pdftron.pdftronflutter.helpers.PluginUtils;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_ANNOTATIONS_SELECTED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_ANNOTATION_CHANGED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_BEHAVIOR_ACTIVATED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_ANNOTATION_MENU_PRESSED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_DOCUMENT_ERROR;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_DOCUMENT_LOADED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_EXPORT_ANNOTATION_COMMAND;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_EXPORT_BOOKMARK;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_FORM_FIELD_VALUE_CHANGED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_LEADING_NAV_BUTTON_PRESSED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_LONG_PRESS_MENU_PRESSED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_PAGE_CHANGED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_PAGE_MOVED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_ZOOM_CHANGED;

import static com.pdftron.pdftronflutter.helpers.PluginUtils.FUNCTION_GET_PLATFORM_VERSION;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.FUNCTION_GET_VERSION;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.FUNCTION_INITIALIZE;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.FUNCTION_OPEN_DOCUMENT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.FUNCTION_SET_LEADING_NAV_BUTTON_ICON;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_CONFIG;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_DOCUMENT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_LEADING_NAV_BUTTON_ICON;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_LICENSE_KEY;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_PASSWORD;

/**
 * PdftronFlutterPlugin
 */
public class PdftronFlutterPlugin implements MethodCallHandler {

    private final Context mContext;

    public PdftronFlutterPlugin(Context context) {
        mContext = context;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel methodChannel = new MethodChannel(registrar.messenger(), "pdftron_flutter");
        methodChannel.setMethodCallHandler(new PdftronFlutterPlugin(registrar.activeContext()));

        final EventChannel annotEventChannel = new EventChannel(registrar.messenger(), EVENT_EXPORT_ANNOTATION_COMMAND);
        annotEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setExportAnnotationCommandEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setExportAnnotationCommandEventEmitter(null);
            }
        });

        final EventChannel bookmarkEventChannel = new EventChannel(registrar.messenger(), EVENT_EXPORT_BOOKMARK);
        bookmarkEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setExportBookmarkEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setExportBookmarkEventEmitter(null);
            }
        });

        final EventChannel documentLoadedEventChannel = new EventChannel(registrar.messenger(), EVENT_DOCUMENT_LOADED);
        documentLoadedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setDocumentLoadedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setDocumentLoadedEventEmitter(null);
            }
        });

        final EventChannel documentErrorEventChannel = new EventChannel(registrar.messenger(), EVENT_DOCUMENT_ERROR);
        documentErrorEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setDocumentErrorEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setDocumentErrorEventEmitter(null);
            }
        });

        final EventChannel annotationChangedEventChannel = new EventChannel(registrar.messenger(), EVENT_ANNOTATION_CHANGED);
        annotationChangedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setAnnotationChangedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setAnnotationChangedEventEmitter(null);
            }
        });

        final EventChannel annotationSelectedEventChannel = new EventChannel(registrar.messenger(), EVENT_ANNOTATIONS_SELECTED);
        annotationSelectedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setAnnotationsSelectionEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setAnnotationsSelectionEventEmitter(null);
            }
        });

        final EventChannel formFieldValueChangedEventChannel = new EventChannel(registrar.messenger(), EVENT_FORM_FIELD_VALUE_CHANGED);
        formFieldValueChangedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setFormFieldValueChangedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setFormFieldValueChangedEventEmitter(null);
            }
        });

        final EventChannel behaviorActivatedEventChannel = new EventChannel(registrar.messenger(), EVENT_BEHAVIOR_ACTIVATED);
        behaviorActivatedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setBehaviorActivatedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setBehaviorActivatedEventEmitter(null);
            }
        });

        final EventChannel longPressMenuPressedEventChannel = new EventChannel(registrar.messenger(), EVENT_LONG_PRESS_MENU_PRESSED);
        longPressMenuPressedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setLongPressMenuPressedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setLongPressMenuPressedEventEmitter(null);
            }
        });

        final EventChannel leadingNavButtonPressedEventChannel = new EventChannel(registrar.messenger(), EVENT_LEADING_NAV_BUTTON_PRESSED);
        leadingNavButtonPressedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setLeadingNavButtonPressedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setLeadingNavButtonPressedEventEmitter(null);
            }
        });

        final EventChannel annotationMenuPressedEventChannel = new EventChannel(registrar.messenger(), EVENT_ANNOTATION_MENU_PRESSED);
        annotationMenuPressedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setAnnotationMenuPressedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setAnnotationMenuPressedEventEmitter(null);
            }
        });

        final EventChannel pageChangedEventChannel = new EventChannel(registrar.messenger(), EVENT_PAGE_CHANGED);
        pageChangedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setPageChangedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setPageChangedEventEmitter(null);
            }
        });

        final EventChannel zoomChangedEventChannel = new EventChannel(registrar.messenger(), EVENT_ZOOM_CHANGED);
        zoomChangedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setZoomChangedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setZoomChangedEventEmitter(null);
            }
        });

        final EventChannel pageMovedEventChanel = new EventChannel(registrar.messenger(), EVENT_PAGE_MOVED);
        pageMovedEventChanel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                FlutterDocumentActivity.setPageMovedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                FlutterDocumentActivity.setPageMovedEventEmitter(null);
            }
        });

        registrar.platformViewRegistry().registerViewFactory("pdftron_flutter/documentview", new DocumentViewFactory(registrar.messenger(), registrar.activeContext()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case FUNCTION_GET_PLATFORM_VERSION:
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case FUNCTION_GET_VERSION:
                try {
                    String pdftronVersion = Double.toString(PDFNet.getVersion());
                    result.success(pdftronVersion);
                } catch (PDFNetException e) {
                    e.printStackTrace();
                    result.error(Long.toString(e.getErrorCode()), "PDFTronException Error: " + e, null);
                }
                break;
            case FUNCTION_INITIALIZE:
                try {
                    String licenseKey = call.argument(KEY_LICENSE_KEY);
                    com.pdftron.pdf.utils.AppUtils.initializePDFNetApplication(mContext.getApplicationContext(), licenseKey);
                    result.success(null);
                } catch (PDFNetException e) {
                    e.printStackTrace();
                    result.error(Long.toString(e.getErrorCode()), "PDFTronException Error: " + e, null);
                }
                break;
            case FUNCTION_OPEN_DOCUMENT:
                String document = call.argument(KEY_DOCUMENT);
                String password = call.argument(KEY_PASSWORD);
                String config = call.argument(KEY_CONFIG);
                FlutterDocumentActivity.setFlutterLoadResult(result);
                FlutterDocumentActivity.openDocument(mContext, document, password, config);
                break;
            case FUNCTION_SET_LEADING_NAV_BUTTON_ICON: {
                String leadingNavButtonIcon = call.argument(KEY_LEADING_NAV_BUTTON_ICON);
                FlutterDocumentActivity.setLeadingNavButtonIcon(leadingNavButtonIcon);
                break;
            }
            default:
                PluginUtils.onMethodCall(call, result, FlutterDocumentActivity.getCurrentActivity());
                break;
        }
    }
}
