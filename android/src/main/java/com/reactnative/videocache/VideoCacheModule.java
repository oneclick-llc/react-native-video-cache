package com.reactnative.videocache;

import android.util.Log;

import com.danikula.videocache.HttpProxyCacheServer;
import com.danikula.videocache.CacheListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

public class VideoCacheModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private HttpProxyCacheServer proxy;

    public VideoCacheModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "VideoCache";
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    public String convert(String url) {
        if (this.proxy == null) {
            this.proxy = new HttpProxyCacheServer(this.reactContext);
        }
        return this.proxy.getProxyUrl(url);
    }

    @ReactMethod
    public void convertAsync(String url, Promise promise) {
        if (this.proxy == null) {
            this.proxy = new HttpProxyCacheServer(this.reactContext);
        }
        promise.resolve(this.proxy.getProxyUrl(url));
    }

    @ReactMethod
    public void convertAndStartDownloadAsync(String videoUrl, int bufLen, Promise promise) {
        if (this.proxy == null) {
            this.proxy = new HttpProxyCacheServer(this.reactContext);
        }

        InputStream inputStream = null;
        String proxyUrl = this.proxy.getProxyUrl(videoUrl);
        if (this.proxy.isCached(videoUrl)) {
          promise.resolve(proxyUrl);
          return;
        }
        try {
            URL url = new URL(proxyUrl);
            inputStream = url.openStream();
            int bufferSize = 1024;
            byte[] buffer = new byte[bufferSize];
            int length = 0;
            int count = 0;
            while ((length = inputStream.read(buffer)) != -1) {
              if (bufLen == 0) continue;
              count ++;
              if (bufLen <= count) break;
            }
            promise.resolve(proxyUrl);
        } catch (Exception e) {
            Log.e("Failed Cache" + videoUrl, e.getMessage());
            promise.reject("0", proxyUrl);
        } finally {
            if(inputStream != null) {
                try {
                    inputStream.close();
                } catch (IOException e) {
                    Log.e("inputStream", e.getMessage());
                }
            }
        }
    }

}
