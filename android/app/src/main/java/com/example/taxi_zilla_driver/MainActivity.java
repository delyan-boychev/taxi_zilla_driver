package com.example.taxi_zilla_driver;

import android.app.IntentService;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstnceState) {
        super.onCreate(savedInstnceState);
        Intent intent = new Intent(getBaseContext(), CloseService.class);
        GlobalVar.engine = getFlutterEngine();
        startService(intent);

    }
    @Override
    protected void onStop() {
        super.onStop();
        FlutterEngine engine = new FlutterEngine(getApplicationContext());
        Log.e("", engine.toString());
        new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), "flutter.temp.channel")
                .invokeMethod("destroy", null, null);
    }
}
