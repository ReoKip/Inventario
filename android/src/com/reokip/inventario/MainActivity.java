package com.reokip.inventario;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Base64;
import android.view.View;
import android.view.Window;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import java.io.OutputStream;
import java.util.ArrayList;

/** Contenedor de la app web de inventario (assets/index.html). */
public class MainActivity extends Activity {
    private static final int REQ_FILE = 1;
    private static final int REQ_SAVE = 2;
    private static final int LIGHT = 0xFFECE3EA;
    private static final int DARK = 0xFF050A1C;

    private WebView web;
    private ValueCallback<Uri[]> fileCallback;
    private int saveId;
    private byte[] saveData;

    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);
        applyBars(false);

        web = new WebView(this);
        web.setBackgroundColor(LIGHT);
        setContentView(web);

        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setDatabaseEnabled(true);
        s.setAllowFileAccess(true);
        s.setTextZoom(100);

        web.addJavascriptInterface(new Bridge(), "AndroidApp");
        web.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (url.startsWith("file:")) return false;
                try { startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url))); } catch (Exception ignored) { }
                return true;
            }
        });
        web.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onShowFileChooser(WebView view, ValueCallback<Uri[]> callback, FileChooserParams params) {
                if (fileCallback != null) fileCallback.onReceiveValue(null);
                fileCallback = callback;
                try {
                    startActivityForResult(Intent.createChooser(pickIntent(params.getAcceptTypes()), null), REQ_FILE);
                    return true;
                } catch (Exception e) {
                    fileCallback = null;
                    return false;
                }
            }
        });

        if (state != null) web.restoreState(state);
        else web.loadUrl("file:///android_asset/index.html");
    }

    /** Arma la petición de archivo a partir del atributo accept del input. */
    private static Intent pickIntent(String[] accept) {
        ArrayList<String> mimes = new ArrayList<String>();
        boolean onlyImages = accept != null && accept.length > 0;
        if (accept != null) {
            for (String raw : accept) {
                for (String a : raw.split(",")) {
                    String t = a.trim();
                    if (t.length() == 0) continue;
                    if (!t.startsWith("image/")) onlyImages = false;
                    if (t.contains("/")) mimes.add(t);
                    else if (t.equals(".csv")) mimes.add("text/csv");
                    else if (t.equals(".json")) mimes.add("application/json");
                }
            }
        }
        Intent i = new Intent(Intent.ACTION_GET_CONTENT);
        i.addCategory(Intent.CATEGORY_OPENABLE);
        if (onlyImages) {
            i.setType("image/*");
        } else {
            i.setType("*/*");
            if (!mimes.isEmpty()) {
                mimes.add("application/octet-stream");
                i.putExtra(Intent.EXTRA_MIME_TYPES, mimes.toArray(new String[0]));
            }
        }
        return i;
    }

    private void applyBars(boolean dark) {
        Window w = getWindow();
        int c = dark ? DARK : LIGHT;
        w.setStatusBarColor(c);
        w.setNavigationBarColor(c);
        View d = w.getDecorView();
        int flags = d.getSystemUiVisibility();
        if (dark) flags &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
        else flags |= View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
        d.setSystemUiVisibility(flags);
        if (web != null) web.setBackgroundColor(c);
    }

    @Override
    protected void onActivityResult(int request, int result, Intent data) {
        if (request == REQ_FILE) {
            Uri[] res = null;
            if (result == RESULT_OK && data != null && data.getData() != null) res = new Uri[]{ data.getData() };
            if (fileCallback != null) fileCallback.onReceiveValue(res);
            fileCallback = null;
            return;
        }
        if (request == REQ_SAVE) {
            int id = saveId;
            byte[] bytes = saveData;
            saveData = null;
            if (result != RESULT_OK || data == null || data.getData() == null) {
                saved(id, false, "declined");
                return;
            }
            try {
                OutputStream out = getContentResolver().openOutputStream(data.getData());
                out.write(bytes);
                out.close();
                saved(id, true, "");
            } catch (Exception e) {
                saved(id, false, "failed");
            }
            return;
        }
        super.onActivityResult(request, result, data);
    }

    private void saved(int id, boolean ok, String code) {
        web.evaluateJavascript("window.__androidSaved&&window.__androidSaved(" + id + "," + ok + ",'" + code + "')", null);
    }

    @Override
    public void onBackPressed() {
        web.evaluateJavascript("(window.__androidBack&&window.__androidBack())?1:0", new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String handled) {
                if (!"1".equals(handled)) finish();
            }
        });
    }

    @Override
    protected void onSaveInstanceState(Bundle out) {
        super.onSaveInstanceState(out);
        web.saveState(out);
    }

    /** Funciones que la página puede llamar como window.AndroidApp.*. */
    private class Bridge {
        @JavascriptInterface
        public void copy(final String text) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    ClipboardManager cm = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
                    cm.setPrimaryClip(ClipData.newPlainText("Stok", text));
                }
            });
        }

        @JavascriptInterface
        public void setTheme(final boolean dark) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() { applyBars(dark); }
            });
        }

        @JavascriptInterface
        public void saveFile(final int id, final String name, final String mime, final String base64) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        saveId = id;
                        saveData = Base64.decode(base64, Base64.DEFAULT);
                        Intent i = new Intent(Intent.ACTION_CREATE_DOCUMENT);
                        i.addCategory(Intent.CATEGORY_OPENABLE);
                        i.setType(mime);
                        i.putExtra(Intent.EXTRA_TITLE, name);
                        startActivityForResult(i, REQ_SAVE);
                    } catch (Exception e) {
                        Toast.makeText(MainActivity.this, "No se pudo guardar el archivo", Toast.LENGTH_SHORT).show();
                        saved(id, false, "failed");
                    }
                }
            });
        }
    }
}
