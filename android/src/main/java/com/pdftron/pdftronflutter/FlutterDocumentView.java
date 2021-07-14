package com.pdftron.pdftronflutter;

import android.content.Context;
import android.view.View;

import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;

import com.pdftron.pdftronflutter.helpers.PluginUtils;
import com.pdftron.pdftronflutter.views.DocumentView;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

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
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_ZOOM_CHANGED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.EVENT_PAGE_MOVED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.FUNCTION_OPEN_DOCUMENT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.FUNCTION_SET_LEADING_NAV_BUTTON_ICON;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_LEADING_NAV_BUTTON_ICON;

public class FlutterDocumentView implements PlatformView, MethodChannel.MethodCallHandler {

    private final DocumentView documentView;

    private final MethodChannel methodChannel;

    public FlutterDocumentView(Context context, Context activityContext, BinaryMessenger messenger, int id) {

        registerWith(messenger);
        documentView = new DocumentView(context);

        FragmentManager manager = null;
        if (activityContext instanceof FragmentActivity) {
            manager = ((FragmentActivity) activityContext).getSupportFragmentManager();
        }

        documentView.setSupportFragmentManager(manager);

        methodChannel = new MethodChannel(messenger, "pdftron_flutter/documentview_" + id);
        methodChannel.setMethodCallHandler(this);
    }

    public void registerWith(BinaryMessenger messenger) {

        final EventChannel annotEventChannel = new EventChannel(messenger, EVENT_EXPORT_ANNOTATION_COMMAND);
        annotEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setExportAnnotationCommandEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setExportAnnotationCommandEventEmitter(null);
            }
        });

        final EventChannel bookmarkEventChannel = new EventChannel(messenger, EVENT_EXPORT_BOOKMARK);
        bookmarkEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setExportBookmarkEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setExportBookmarkEventEmitter(null);
            }
        });

        final EventChannel documentLoadedEventChannel = new EventChannel(messenger, EVENT_DOCUMENT_LOADED);
        documentLoadedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setDocumentLoadedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setDocumentLoadedEventEmitter(null);
            }
        });

        final EventChannel documentErrorEventChannel = new EventChannel(messenger, EVENT_DOCUMENT_ERROR);
        documentErrorEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setDocumentErrorEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setDocumentErrorEventEmitter(null);
            }
        });

        final EventChannel annotationChangedEventChannel = new EventChannel(messenger, EVENT_ANNOTATION_CHANGED);
        annotationChangedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setAnnotationChangedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setAnnotationChangedEventEmitter(null);
            }
        });

        final EventChannel annotationSelectedEventChannel = new EventChannel(messenger, EVENT_ANNOTATIONS_SELECTED);
        annotationSelectedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setAnnotationsSelectedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setAnnotationsSelectedEventEmitter(null);
            }
        });

        final EventChannel formFieldValueChangedEventChannel = new EventChannel(messenger, EVENT_FORM_FIELD_VALUE_CHANGED);
        formFieldValueChangedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setFormFieldValueChangedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setFormFieldValueChangedEventEmitter(null);
            }
        });

        final EventChannel behaviorActivatedEventChannel = new EventChannel(messenger, EVENT_BEHAVIOR_ACTIVATED);
        behaviorActivatedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setBehaviorActivatedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setBehaviorActivatedEventEmitter(null);
            }
        });

        final EventChannel longPressMenuPressedEventChannel = new EventChannel(messenger, EVENT_LONG_PRESS_MENU_PRESSED);
        longPressMenuPressedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setLongPressMenuPressedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setLongPressMenuPressedEventEmitter(null);
            }
        });

        final EventChannel annotationMenuPressedEventChannel = new EventChannel(messenger, EVENT_ANNOTATION_MENU_PRESSED);
        annotationMenuPressedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setAnnotationMenuPressedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setAnnotationMenuPressedEventEmitter(null);
            }
        });

        final EventChannel leadingNavButtonPressedEventChannel = new EventChannel(messenger, EVENT_LEADING_NAV_BUTTON_PRESSED);
        leadingNavButtonPressedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setLeadingNavButtonPressedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setLeadingNavButtonIcon(null);
            }
        });

        final EventChannel pageChangedEventChannel = new EventChannel(messenger, EVENT_PAGE_CHANGED);
        pageChangedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setPageChangedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setPageChangedEventEmitter(null);
            }
        });

        final EventChannel zoomChangedEventChannel = new EventChannel(messenger, EVENT_ZOOM_CHANGED);
        zoomChangedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setZoomChangedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setZoomChangedEventEmitter(null);
            }
        });

        final EventChannel pageMovedEventChannel = new EventChannel(messenger, EVENT_PAGE_MOVED);
        pageMovedEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink emitter) {
                documentView.setPageMovedEventEmitter(emitter);
            }

            @Override
            public void onCancel(Object arguments) {
                documentView.setPageMovedEventEmitter(null);
            }
        });
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case FUNCTION_OPEN_DOCUMENT:
                String document = call.argument("document");
                String password = call.argument("password");
                String config = call.argument("config");
                documentView.openDocument(document, password, config, result);
                break;
            case FUNCTION_SET_LEADING_NAV_BUTTON_ICON: {
                String leadingNavButtonIcon = call.argument(KEY_LEADING_NAV_BUTTON_ICON);
                documentView.setLeadingNavButtonIcon(leadingNavButtonIcon);
                break;
            }
            default:
                PluginUtils.onMethodCall(call, result, documentView);
                break;
        }
    }

    @Override
    public View getView() {
        return documentView;
    }

    @Override
    public void dispose() {
    }
}
