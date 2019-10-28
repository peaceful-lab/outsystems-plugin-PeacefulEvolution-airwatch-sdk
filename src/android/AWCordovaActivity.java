/*
 * Copyright (c) 2017 AirWatch, LLC. All rights reserved.
 *  This product is protected by copyright and intellectual property laws in  the United States and other countries
 *  as well as by international treaties.
 *  AirWatch products may be covered by one or more patents listed at
 *  http://www.vmware.com/go/patents.
 */
package com.airwatch.cordova.sdkplugin;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebView;

import com.airwatch.geofencing.GeofencingUtility;
import com.airwatch.login.IProxyStatusCallback;
import com.airwatch.login.SDKBaseActivityDelegate;
import com.airwatch.login.SDKGatewayActivityDelegate;
import com.airwatch.sdk.configuration.SDKConfiguration;
import com.airwatch.sdk.configuration.SDKConfigurationKeys;
import com.airwatch.sdk.context.SDKContextManager;

import org.apache.cordova.CordovaActivity;

/**
 * Created by josephben on 1/5/2017.
 */

public class AWCordovaActivity extends CordovaActivity implements SDKBaseActivityDelegate.Callback, IProxyStatusCallback
{

    protected SDKBaseActivityDelegate mSDKBaseActivityDelegate;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (mSDKBaseActivityDelegate == null) {
            mSDKBaseActivityDelegate = new SDKGatewayActivityDelegate(this);
        }
        mSDKBaseActivityDelegate.onCreate(savedInstanceState);

        // enable Cordova apps to be started in the background
        Bundle extras = getIntent().getExtras();
        if (extras != null && extras.getBoolean("cdvStartInBackground", false)) {
            moveTaskToBack(true);
        }

        // Set by <content src="index.html" /> in config.xml
        loadUrl(launchUrl);
    }


    @Override
    protected void onResume() {
        super.onResume();
        //shake device to feedBack listener
        mSDKBaseActivityDelegate.onResume();
        if (mSDKBaseActivityDelegate.isAppReady()) {
            SDKConfiguration sdkConfiguration = SDKContextManager.getSDKContext().getSDKConfiguration();
            boolean isGeofencingEnable = sdkConfiguration.getBooleanValue(SDKConfigurationKeys.GEOFENCE_GROUP, SDKConfigurationKeys.ENABLE_GEOFENCING);
            if (isGeofencingEnable) {
                GeofencingUtility gps = GeofencingUtility.getInstance();
                gps.checkGeofencingControl(this);
            }
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        mSDKBaseActivityDelegate.onPause();
    }

    public boolean isInForeground() {
        return mSDKBaseActivityDelegate.isActivityInForeground();
    }

    public void lockSession(){
        mSDKBaseActivityDelegate.lockSession();
    }

    protected void startLauncherActivity() {
        mSDKBaseActivityDelegate.startLauncherActivity();
    }

    @Override
    protected void onStart() {
        super.onStart();
        mSDKBaseActivityDelegate.onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();
        mSDKBaseActivityDelegate.onStop();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        mSDKBaseActivityDelegate.onActivityResult(requestCode, resultCode, data);
    }

    /**
     * this api will work in case of sso disabled only
     */
    protected void logout(){
        mSDKBaseActivityDelegate.logout();
    }

    /**
     * this api will work in case of sso disabled and authentication type is passcode
     */
    protected void changePasscode(){
        mSDKBaseActivityDelegate.changePasscode();
    }

    @Override
    public void onTimeOut(SDKBaseActivityDelegate delegate) {
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mSDKBaseActivityDelegate.onDestroy();
    }



    @Override
    public void proxyStatusUpdated(int i) {

    }

    public boolean isTunnelingEnabled() {
        return ((SDKGatewayActivityDelegate)mSDKBaseActivityDelegate).isTunnelingEnabled();
    }

    public static Context getContext(){
        return getContext();
    }

    public WebView getWebView(){
        return (WebView)appView.getEngine().getView();
    }
}
