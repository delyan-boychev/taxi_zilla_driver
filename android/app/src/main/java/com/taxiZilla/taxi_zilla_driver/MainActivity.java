package com.taxiZilla.taxi_zilla_driver;

import android.content.Intent;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstnceState) {
        super.onCreate(savedInstnceState);
        Intent intent = new Intent(getBaseContext(), CloseService.class);
        startService(intent);

    }
}
