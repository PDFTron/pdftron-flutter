package com.pdftron.pdftronflutter;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pdftron.pdf.Annot;
import com.pdftron.pdf.PDFDoc;
import com.pdftron.pdf.PDFViewCtrl;
import com.pdftron.pdf.config.PDFViewCtrlConfig;
import com.pdftron.pdf.config.ToolManagerBuilder;
import com.pdftron.pdf.config.ViewerBuilder2;
import com.pdftron.pdf.config.ViewerConfig;
import com.pdftron.pdf.controls.DocumentActivity;
import com.pdftron.pdf.controls.PdfViewCtrlTabFragment2;
import com.pdftron.pdf.controls.PdfViewCtrlTabHostFragment2;
import com.pdftron.pdf.tools.ToolManager;
import com.pdftron.pdf.utils.Utils;
import com.pdftron.pdftronflutter.helpers.PluginUtils;
import com.pdftron.pdftronflutter.helpers.ViewerComponent;
import com.pdftron.pdftronflutter.helpers.ViewerImpl;

import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.concurrent.atomic.AtomicReference;

import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.MethodChannel.Result;

import static com.pdftron.pdftronflutter.helpers.PluginUtils.handleLeadingNavButtonPressed;

public class FlutterDocumentActivity extends DocumentActivity implements ViewerComponent {

    private ViewerImpl mImpl = new ViewerImpl(this);

    private static ArrayList<String> mLongPressMenuItems;
    private static ArrayList<String> mLongPressMenuOverrideItems;
    private static ArrayList<String> mHideAnnotationMenuTools;
    private static ArrayList<String> mAnnotationMenuItems;
    private static ArrayList<String> mAnnotationMenuOverrideItems;
    private static boolean mAutoSaveEnabled;
    private static boolean mUseStylusAsPen;
    private static boolean mSignSignatureFieldWithStamps;
    private static boolean mShowLeadingNavButton;
    private static ArrayList<String> mActionOverrideItems;

    private static FlutterDocumentActivity sCurrentActivity;

    private static ArrayList<File> mTempFiles = new ArrayList<>();

    private static boolean mIsBase64;
    private static int mInitialPageNumber;

    private static AtomicReference<Result> sFlutterLoadResult = new AtomicReference<>();

    private static AtomicReference<EventSink> sExportAnnotationCommandEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sExportBookmarkEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sDocumentLoadedEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sDocumentErrorEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sAnnotationChangedEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sAnnotationsSelectionEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sFormFieldChangedEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sBehaviorActivatedEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sLongPressMenuPressedEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sAnnotationMenuPressedEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sLeadingNavButtonPressedEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sPageChangedEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sZoomChangedEventEmitter = new AtomicReference<>();
    private static AtomicReference<EventSink> sPageMovedEventEmitter = new AtomicReference<>();

    private static HashMap<Annot, Integer> mSelectedAnnots;

    public static void openDocument(Context packageContext, String document, String password, String configStr) {

        ViewerConfig.Builder builder = new ViewerConfig.Builder();

        ToolManagerBuilder toolManagerBuilder = ToolManagerBuilder.from();
        PDFViewCtrlConfig pdfViewCtrlConfig = PDFViewCtrlConfig.getDefaultConfig(packageContext);
        PluginUtils.ConfigInfo configInfo = PluginUtils.handleOpenDocument(builder, toolManagerBuilder, pdfViewCtrlConfig, document, packageContext, configStr);

        mTempFiles.add(configInfo.getTempFile());

        mIsBase64 = configInfo.isBase64();
        mInitialPageNumber = configInfo.getInitialPageNumber();
        mLongPressMenuItems = configInfo.getLongPressMenuItems();
        mLongPressMenuOverrideItems = configInfo.getLongPressMenuOverrideItems();
        mHideAnnotationMenuTools = configInfo.getHideAnnotationMenuTools();
        mAnnotationMenuItems = configInfo.getAnnotationMenuItems();
        mAnnotationMenuOverrideItems = configInfo.getAnnotationMenuOverrideItems();

        mAutoSaveEnabled = configInfo.isAutoSaveEnabled();
        mUseStylusAsPen = configInfo.isUseStylusAsPen();
        mSignSignatureFieldWithStamps = configInfo.isSignSignatureFieldWithStamps();

        mShowLeadingNavButton = configInfo.isShowLeadingNavButton();
        mActionOverrideItems = configInfo.getActionOverrideItems();

        if (mShowLeadingNavButton) {
            openDocument(packageContext, configInfo.getFileUri(), password, configInfo.getCustomHeaderJson(), builder.build());
        } else {
            openDocument(packageContext, configInfo.getFileUri(), password, configInfo.getCustomHeaderJson(), builder.build(), 0);
        }
    }

    public static void openDocument(Context packageContext, Uri fileUri, String password, @Nullable JSONObject customHeaders, ViewerConfig config) {
        openDocument(packageContext, fileUri, password, customHeaders, config, DEFAULT_NAV_ICON_ID);
    }

    public static void openDocument(Context packageContext, Uri fileUri, String password, @Nullable JSONObject customHeaders, ViewerConfig config, @DrawableRes int navIconId) {

        if (getCurrentActivity() != null && getCurrentActivity().getPdfViewCtrlTabHostFragment() != null) {

            ViewerBuilder2 viewerBuilder = ViewerBuilder2.withUri(fileUri, password)
                    .usingCustomHeaders(customHeaders)
                    .usingConfig(config)
                    .usingNavIcon(navIconId);

            getCurrentActivity().getPdfViewCtrlTabHostFragment().onOpenAddNewTab(viewerBuilder.createBundle(packageContext));
        } else {
            DocumentActivity.IntentBuilder intentBuilder = DocumentActivity.IntentBuilder.fromActivityClass(packageContext, FlutterDocumentActivity.class);

            if (null != fileUri) {
                intentBuilder.withUri(fileUri);
            }

            if (null != password) {
                intentBuilder.usingPassword(password);
            }

            if (null != customHeaders) {
                intentBuilder.usingCustomHeaders(customHeaders);
            }

            intentBuilder.usingNavIcon(navIconId);
            intentBuilder.usingConfig(config);
            intentBuilder.usingNewUi(true);
            packageContext.startActivity(intentBuilder.build());
        }
    }

    public int getInitialPageNumber() {
        return mInitialPageNumber;
    }

    public boolean isBase64() {
        return mIsBase64;
    }

    public ArrayList<File> getTempFiles() {
        return mTempFiles;
    }

    public static void setLeadingNavButtonIcon(String leadingNavButtonIcon) {
        FlutterDocumentActivity documentActivity = getCurrentActivity();
        if (documentActivity != null) {
            PdfViewCtrlTabHostFragment2 pdfViewCtrlTabHostFragment = documentActivity.getPdfViewCtrlTabHostFragment();
            if (mShowLeadingNavButton && pdfViewCtrlTabHostFragment != null
                    && pdfViewCtrlTabHostFragment.getToolbar() != null) {
                int res = Utils.getResourceDrawable(pdfViewCtrlTabHostFragment.getToolbar().getContext(), leadingNavButtonIcon);
                if (res != 0) {
                    pdfViewCtrlTabHostFragment.getToolbar().setNavigationIcon(res);
                }
            }
        }
    }

    public static void setExportAnnotationCommandEventEmitter(EventSink emitter) {
        sExportAnnotationCommandEventEmitter.set(emitter);
    }

    public static void setExportBookmarkEventEmitter(EventSink emitter) {
        sExportBookmarkEventEmitter.set(emitter);
    }

    public static void setDocumentLoadedEventEmitter(EventSink emitter) {
        sDocumentLoadedEventEmitter.set(emitter);
    }

    public static void setDocumentErrorEventEmitter(EventSink emitter) {
        sDocumentErrorEventEmitter.set(emitter);
    }

    public static void setAnnotationChangedEventEmitter(EventSink emitter) {
        sAnnotationChangedEventEmitter.set(emitter);
    }

    public static void setAnnotationsSelectionEventEmitter(EventSink emitter) {
        sAnnotationsSelectionEventEmitter.set(emitter);
    }

    public static void setFormFieldValueChangedEventEmitter(EventSink emitter) {
        sFormFieldChangedEventEmitter.set(emitter);
    }

    public static void setBehaviorActivatedEventEmitter(EventSink emitter) {
        sBehaviorActivatedEventEmitter.set(emitter);
    }

    public static void setLongPressMenuPressedEventEmitter(EventSink emitter) {
        sLongPressMenuPressedEventEmitter.set(emitter);
    }

    public static void setAnnotationMenuPressedEventEmitter(EventSink emitter) {
        sAnnotationMenuPressedEventEmitter.set(emitter);
    }

    public static void setLeadingNavButtonPressedEventEmitter(EventSink emitter) {
        sLeadingNavButtonPressedEventEmitter.set(emitter);
    }

    public static void setPageChangedEventEmitter(EventSink emitter) {
        sPageChangedEventEmitter.set(emitter);
    }

    public static void setZoomChangedEventEmitter(EventSink emitter) {
        sZoomChangedEventEmitter.set(emitter);
    }

    public static void setPageMovedEventEmitter(EventSink emitter) {
        sPageMovedEventEmitter.set(emitter);
    }

    public static void setFlutterLoadResult(Result result) {
        sFlutterLoadResult.set(result);
    }

    public void setSelectedAnnots(HashMap<Annot, Integer> selectedAnnots) {
        mSelectedAnnots = selectedAnnots;
    }

    @Override
    public EventSink getExportAnnotationCommandEventEmitter() {
        return sExportAnnotationCommandEventEmitter.get();
    }

    @Override
    public EventSink getExportBookmarkEventEmitter() {
        return sExportBookmarkEventEmitter.get();
    }

    @Override
    public EventSink getDocumentLoadedEventEmitter() {
        return sDocumentLoadedEventEmitter.get();
    }

    @Override
    public EventSink getDocumentErrorEventEmitter() {
        return sDocumentErrorEventEmitter.get();
    }

    @Override
    public EventSink getAnnotationChangedEventEmitter() {
        return sAnnotationChangedEventEmitter.get();
    }

    @Override
    public EventSink getAnnotationsSelectedEventEmitter() {
        return sAnnotationsSelectionEventEmitter.get();
    }

    @Override
    public EventSink getFormFieldValueChangedEventEmitter() {
        return sFormFieldChangedEventEmitter.get();
    }

    @Override
    public EventSink getBehaviorActivatedEventEmitter() {
        return sBehaviorActivatedEventEmitter.get();
    }

    @Override
    public EventSink getLongPressMenuPressedEventEmitter() {
        return sLongPressMenuPressedEventEmitter.get();
    }

    @Override
    public EventSink getAnnotationMenuPressedEventEmitter() {
        return sAnnotationMenuPressedEventEmitter.get();
    }

    public EventSink getLeadingNavButtonPressedEventEmitter() {
        return sLeadingNavButtonPressedEventEmitter.get();
    }

    @Override
    public EventSink getPageChangedEventEmitter() {
        return sPageChangedEventEmitter.get();
    }

    @Override
    public EventSink getZoomChangedEventEmitter() {
        return sZoomChangedEventEmitter.get();
    }

    @Override
    public EventSink getPageMovedEventEmitter() { return sPageMovedEventEmitter.get(); }

    @Override
    public Result getFlutterLoadResult() {
        return sFlutterLoadResult.getAndSet(null);
    }

    @Override
    public HashMap<Annot, Integer> getSelectedAnnots() {
        return mSelectedAnnots;
    }

    @Override
    public ArrayList<String> getActionOverrideItems() {
        return mActionOverrideItems;
    }

    @Override
    public ArrayList<String> getLongPressMenuItems() {
        return mLongPressMenuItems;
    }

    @Override
    public ArrayList<String> getLongPressMenuOverrideItems() {
        return mLongPressMenuOverrideItems;
    }

    @Override
    public ArrayList<String> getHideAnnotationMenuTools() {
        return mHideAnnotationMenuTools;
    }

    @Override
    public ArrayList<String> getAnnotationMenuItems() {
        return mAnnotationMenuItems;
    }

    @Override
    public ArrayList<String> getAnnotationMenuOverrideItems() {
        return mAnnotationMenuOverrideItems;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        attachActivity();
    }

    @Override
    protected void onDestroy() {
        PluginUtils.handleOnDetach(this);

        super.onDestroy();

        sExportAnnotationCommandEventEmitter.set(null);
        sExportBookmarkEventEmitter.set(null);
        sDocumentLoadedEventEmitter.set(null);
        sDocumentErrorEventEmitter.set(null);
        sAnnotationChangedEventEmitter.set(null);
        sAnnotationsSelectionEventEmitter.set(null);
        sFormFieldChangedEventEmitter.set(null);
        sLongPressMenuPressedEventEmitter.set(null);
        sAnnotationMenuPressedEventEmitter.set(null);
        sLeadingNavButtonPressedEventEmitter.set(null);
        sPageChangedEventEmitter.set(null);
        sZoomChangedEventEmitter.set(null);
        sPageMovedEventEmitter.set(null);

        detachActivity();
    }

    @Override
    public void onTabDocumentLoaded(String tag) {
        super.onTabDocumentLoaded(tag);

        PluginUtils.handleDocumentLoaded(this);
    }

    @Override
    public boolean onOpenDocError() {
        super.onOpenDocError();

        return PluginUtils.handleOpenDocError(this);
    }

    public boolean isAutoSaveEnabled() {
        return mAutoSaveEnabled;
    }

    public boolean isUseStylusAsPen() {
        return mUseStylusAsPen;
    }

    public boolean isSignSignatureFieldWithStamps() {
        return mSignSignatureFieldWithStamps;
    }

    @Override
    public void onNavButtonPressed() {
        handleLeadingNavButtonPressed(this);

        super.onNavButtonPressed();
    }

    private void attachActivity() {
        sCurrentActivity = this;
    }

    private void detachActivity() {
        sCurrentActivity = null;
    }

    public static FlutterDocumentActivity getCurrentActivity() {
        return sCurrentActivity;
    }

    // Convenience

    @Nullable
    public PdfViewCtrlTabHostFragment2 getPdfViewCtrlTabHostFragment() {
        return mPdfViewCtrlTabHostFragment2;
    }

    @Nullable
    public PdfViewCtrlTabFragment2 getPdfViewCtrlTabFragment() {
        if (mPdfViewCtrlTabHostFragment2 != null) {
            return mPdfViewCtrlTabHostFragment2.getCurrentPdfViewCtrlFragment();
        }
        return null;
    }

    @Nullable
    public PDFViewCtrl getPdfViewCtrl() {
        if (getPdfViewCtrlTabFragment() != null) {
            return getPdfViewCtrlTabFragment().getPDFViewCtrl();
        }
        return null;
    }

    @Nullable
    public ToolManager getToolManager() {
        if (getPdfViewCtrlTabFragment() != null) {
            return getPdfViewCtrlTabFragment().getToolManager();
        }
        return null;
    }

    @Nullable
    public PDFDoc getPdfDoc() {
        if (getPdfViewCtrlTabFragment() != null) {
            return getPdfViewCtrlTabFragment().getPdfDoc();
        }
        return null;
    }

    @NonNull
    @Override
    public ViewerImpl getImpl() {
        return mImpl;
    }
}
