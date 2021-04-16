package com.taxiZilla.taxi_zilla_driver;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.IBinder;
import android.os.StrictMode;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import org.apache.commons.net.ntp.NTPUDPClient;
import org.apache.commons.net.ntp.TimeInfo;

import java.io.DataOutputStream;
import java.io.File;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Scanner;
import java.util.TimeZone;

public class CloseService extends Service {
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
    @RequiresApi(api = Build.VERSION_CODES.O)
    private void startMyOwnForeground(){
        String NOTIFICATION_CHANNEL_ID = "com.taxiZilla.taxi_zilla_driver";
        String channelName = "taxiZilla Background service";
        NotificationChannel chan = new NotificationChannel(NOTIFICATION_CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_NONE);
        chan.setLightColor(Color.BLUE);
        chan.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
        NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        assert manager != null;
        manager.createNotificationChannel(chan);

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID);
        Notification notification = notificationBuilder.setOngoing(true)
                .setSmallIcon(R.drawable.notification)
                .setContentTitle("taxiZilla работи на фонов режим!")
                .setPriority(NotificationManager.IMPORTANCE_MIN)
                .setCategory(Notification.CATEGORY_SERVICE)
                .build();
        startForeground(2, notification);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if(Build.VERSION.SDK_INT >25){
            startMyOwnForeground();
        }
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    static String getAlphaNumericString(int n) {
        String AlphaNumericString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + "0123456789" + "abcdefghijklmnopqrstuvxyz" + "&%$#@";

        StringBuilder sb = new StringBuilder(n);

        for (int i = 0; i < n; i++) {
            int index = (int) (AlphaNumericString.length() * Math.random());
            sb.append(AlphaNumericString.charAt(index));
        }

        return sb.toString();
    }

    public String generateKey() {
        TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
        Date date = new Date();
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyddMMHHmmss");
        String data = formatter.format(date);
        String result = "";
        for (int i = 0; i < data.length(); i += 2) {
            char tmp = (char) ((data.charAt(i) - '0') * 10 + (data.charAt(i + 1) - '0'));
            tmp += 33;
            result += String.valueOf(tmp);
        }
        result = getAlphaNumericString(6) + result + getAlphaNumericString(6);
        return result;
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        try {
            NTPUDPClient client = new NTPUDPClient();
            client.open();
            InetAddress hostAddr = InetAddress.getByName("0.bg.pool.ntp.org");
            TimeInfo info = client.getTime(hostAddr);
            info.computeDetails(); // compute offset/delay if not already done
            Long offsetValue = info.getOffset();
            Long delayValue = info.getDelay();
            String delay = (delayValue == null) ? "N/A" : delayValue.toString();
            String offset = (offsetValue == null) ? "N/A" : offsetValue.toString();
            File folder = this.getExternalFilesDir(null);
            if (new File(folder, "credentials").isFile() && new File(folder, "driverID").isFile()) {
                String lastOrderID = "none";
                File myFile = new File(folder, "driverID");
                Scanner reader = new Scanner(myFile);
                String id = reader.nextLine();
                if(new File(folder, "lastOrderID").isFile()) {
                    File myFile2 = new File(folder, "lastOrderID");
                    Scanner reader2 = new Scanner(myFile2);
                    lastOrderID = reader2.nextLine();
                }
                URL url = new URL("https://taxizillabg.com/auth/exitTaxiDriver");
                HttpURLConnection con = (HttpURLConnection) url.openConnection();
                con.setRequestMethod("POST");
                con.setRequestProperty("Content-Type", "application/json");
                con.setDoOutput(true);
                DataOutputStream out = new DataOutputStream(con.getOutputStream());
                String jsonInputString = "{\"driverID\": \"" + id + "\", \"lastOrderID\": \"" + lastOrderID + "\", \"key\": \"" + generateKey() + "\", \"offset\": \""+ offset +"\"}";
                try (OutputStream os = con.getOutputStream()) {
                    byte[] input = jsonInputString.getBytes("utf-8");
                    os.write(input, 0, input.length);
                }
                out.flush();
                out.close();
                con.getResponseCode();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        if(Build.VERSION.SDK_INT >25) {
            stopForeground(true);
        }
        stopSelf();
    }
}
