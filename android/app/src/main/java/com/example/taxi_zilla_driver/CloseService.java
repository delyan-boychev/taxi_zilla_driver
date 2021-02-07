package com.example.taxi_zilla_driver;

import android.app.Service;
import android.content.Intent;
import android.os.Environment;
import android.os.IBinder;
import android.os.StrictMode;
import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.service.ServiceAware;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;

import androidx.annotation.Nullable;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.Charset;
import java.text.SimpleDateFormat;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
import java.util.Random;
import java.util.Scanner;
import java.util.TimeZone;

public class CloseService extends Service {
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_NOT_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
    static String getAlphaNumericString(int n)
    {
        String AlphaNumericString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                + "0123456789"
                + "abcdefghijklmnopqrstuvxyz" + "&%$#@";

        StringBuilder sb = new StringBuilder(n);

        for (int i = 0; i < n; i++) {
            int index
                    = (int)(AlphaNumericString.length()
                    * Math.random());
            sb.append(AlphaNumericString
                    .charAt(index));
        }

        return sb.toString();
    }
    public String generateKey()
    {
        TimeZone.setDefault( TimeZone.getTimeZone("UTC"));
        Date date = new Date();
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyddMMHHmmss");
        String data = formatter.format(date);
        String result="";
        for(int i=0;i<data.length();i+=2)
        {
            char tmp = (char) ((data.charAt(i)-'0')*10+(data.charAt(i+1)-'0'));
            tmp+=33;
            result+= String.valueOf(tmp);
        }
        result = getAlphaNumericString(6) + result + getAlphaNumericString(6);
        return result;
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder()
                .permitAll().build();
        StrictMode.setThreadPolicy(policy);
        try {
            File folder = this.getExternalFilesDir(null);
            File myFile = new File(folder, "driverID");
            Scanner reader = new Scanner(myFile);
            String id = reader.nextLine();
            URL url = new URL("https://taxizillabg.com/auth/exitTaxiDriver");
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("POST");
            con.setRequestProperty("Content-Type", "application/json");
            con.setDoOutput(true);
            DataOutputStream out = new DataOutputStream(con.getOutputStream());
            String jsonInputString = "{\"driverID\": \""+ id +"\", \"key\": \""+ generateKey() +"\"}";
            try(OutputStream os = con.getOutputStream()) {
                byte[] input = jsonInputString.getBytes("utf-8");
                os.write(input, 0, input.length);
            }
            out.flush();
            out.close();
            con.getResponseCode();
        } catch (Exception e) {
            e.printStackTrace();
        }
        stopSelf();
    }
}
