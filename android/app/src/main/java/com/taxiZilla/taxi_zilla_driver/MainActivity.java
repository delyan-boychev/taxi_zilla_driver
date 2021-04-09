package com.taxiZilla.taxi_zilla_driver;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.WindowManager;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    String CHANNEL = "taxiZillaMethodChannel";
    @Override
    protected void onCreate(Bundle savedInstnceState) {
        super.onCreate(savedInstnceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        Intent intent = new Intent(getBaseContext(), CloseService.class);
        if(Build.VERSION.SDK_INT >25){
            startForegroundService(intent);
        }else{
            startService(intent);
        }
        MethodChannel chan = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL);
        Handler handler = new Handler(Looper.getMainLooper());
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                chan.invokeMethod("checkForOrdersAndSetLocation",  savedInstnceState);
                handler.postDelayed(this, 4000); // Optional, to repeat the task.
            }
        };
        handler.postDelayed(runnable, 4000);
    }
}
