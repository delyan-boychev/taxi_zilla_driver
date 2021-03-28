package com.taxiZilla.taxi_zilla_driver;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    String CHANNEL = "taxiZillaMethodChannel";
    @Override
    protected void onCreate(Bundle savedInstnceState) {
        super.onCreate(savedInstnceState);
        Intent intent = new Intent(getBaseContext(), CloseService.class);
        startService(intent);
        MethodChannel chan = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL);
        final Handler h = new Handler();
        h.postDelayed(new Runnable()
        {

            @Override
            public void run()
            {
                chan.invokeMethod("checkForOrdersAndSetLocation",  savedInstnceState);
                h.postDelayed(this, 4000);
            }
        }, 4000); // 1 second delay (takes millis)
    }
}
