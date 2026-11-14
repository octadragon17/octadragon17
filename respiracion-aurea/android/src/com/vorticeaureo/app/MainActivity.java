package com.vorticeaureo.app;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Vibrator;
import android.speech.tts.TextToSpeech;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import org.json.JSONArray;

import java.util.Locale;

/** Contenedor WebView sin red: carga assets/index.html y expone voz (TTS) y vibración nativas. */
public class MainActivity extends Activity {

    private WebView web;
    private TextToSpeech tts;
    private boolean ttsReady = false;

    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);
        Window w = getWindow();
        w.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        w.setStatusBarColor(Color.parseColor("#0d1419"));
        w.setNavigationBarColor(Color.parseColor("#0d1419"));

        web = new WebView(this);
        web.setBackgroundColor(Color.parseColor("#0d1419"));
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setMediaPlaybackRequiresUserGesture(false);
        s.setAllowContentAccess(false);
        s.setCacheMode(WebSettings.LOAD_NO_CACHE);
        s.setTextZoom(100);
        web.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                return !url.startsWith("file:///android_asset/");
            }
        });
        web.setWebChromeClient(new WebChromeClient());
        web.addJavascriptInterface(new Bridge(), "AndroidBridge");
        setContentView(web);

        if (state != null) web.restoreState(state);
        else web.loadUrl("file:///android_asset/index.html");

        tts = new TextToSpeech(this, new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {
                if (status != TextToSpeech.SUCCESS) return;
                int r = tts.setLanguage(new Locale("es", "MX"));
                if (r == TextToSpeech.LANG_MISSING_DATA || r == TextToSpeech.LANG_NOT_SUPPORTED) {
                    tts.setLanguage(new Locale("es"));
                }
                tts.setSpeechRate(0.9f);
                ttsReady = true;
            }
        });
    }

    @Override
    protected void onSaveInstanceState(Bundle out) {
        super.onSaveInstanceState(out);
        web.saveState(out);
    }

    @Override
    public void onBackPressed() {
        moveTaskToBack(true);
    }

    @Override
    protected void onDestroy() {
        if (tts != null) tts.shutdown();
        web.destroy();
        super.onDestroy();
    }

    private class Bridge {
        @JavascriptInterface
        public void speak(String text) {
            if (ttsReady && text != null) {
                if (Build.VERSION.SDK_INT >= 21) tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "cue");
            }
        }

        @JavascriptInterface
        public void vibrate(String patternJson) {
            try {
                Vibrator v = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
                if (v == null || !v.hasVibrator()) return;
                JSONArray a = new JSONArray(patternJson);
                if (a.length() == 1) { v.vibrate(a.getLong(0)); return; }
                long[] p = new long[a.length() + 1];
                p[0] = 0;
                for (int i = 0; i < a.length(); i++) p[i + 1] = a.getLong(i);
                v.vibrate(p, -1);
            } catch (Exception ignored) { }
        }
    }
}
