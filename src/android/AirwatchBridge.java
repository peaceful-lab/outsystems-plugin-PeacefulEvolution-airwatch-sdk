//
//  AirwatchBridge.java
//  Airwatch Plugin
//
//  Copyright (C) 2016 VMWare AirWatch. All rights reserved.
//  This product is protected by copyright and intellectual property laws in the
//  United States and other countries as well as by international treaties.
//  AirWatch products may be covered by one or more patents listed at
//  http://www.vmware.com/go/patents.
//

package com.airwatch.cordova.sdkplugin;

import android.app.Activity;
import android.net.Uri;
import android.text.TextUtils;

import com.airwatch.dlp.openIn.UriOpenerFactory;
import com.airwatch.sdk.AirWatchSDKException;
import com.airwatch.sdk.SDKManager;
import com.airwatch.sdk.profile.RestrictionPolicy;
import com.airwatch.sdk.configuration.SDKConfiguration;
import com.airwatch.sdk.configuration.SDKConfigurationKeys;
import com.airwatch.sdk.context.SDKContextManager;
import com.airwatch.util.Logger;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by josephben on 3/8/2016.
 */
public class AirwatchBridge {

    private static final String LOG_TAG = AirwatchBridge.class.getSimpleName();
    private static AirwatchBridge instance = new AirwatchBridge();
    private SDKManager awSDKManager;
    private Activity cordovaActivity;


    public void initAirwatchSDKManager(final Activity activity, final AirwatchSDKPlugin.InitializationListener initListener) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    awSDKManager = SDKManager.init(activity.getApplicationContext());
                    initListener.initSuccess();
                    cordovaActivity=activity;
                } catch (AirWatchSDKException awse) {
                    Logger.e(LOG_TAG, "Exception initializing AirWatch SDK", awse);
                    initListener.initFailure();
                }
            }
        }).start();
    }

    public SDKManager getSDKManagerInstance() {
        return awSDKManager;
    }

    public static AirwatchBridge getInstance() {
        return instance;
    }

    public boolean isInitialized() throws AirWatchSDKException {
        return (awSDKManager != null);
    }

    // Connection information

    public String getUserName() throws AirWatchSDKException {
        return awSDKManager.getSecureAppInfo().getEnrollmentUsername();
    }

    public String getGroupId() throws AirWatchSDKException {
        return awSDKManager.getGroupId();
    }

    public String getServerName() throws AirWatchSDKException {
        return awSDKManager.getServerName();
    }
    
    // Restrictions methods

    public boolean allowCopyPaste() throws AirWatchSDKException {
        RestrictionPolicy restrictionPolicy = awSDKManager.getRestrictionPolicy();
        return (restrictionPolicy == null) || !restrictionPolicy.preventCopyAndCutActions();
    }

    public boolean isOfflineAllowed() throws AirWatchSDKException {
        SDKConfiguration config=SDKContextManager.getSDKContext().getSDKConfiguration();
        String allowOffline = config.getValuesWithKeyStartWith(SDKConfigurationKeys.TYPE_OFFLINE_ACCESS,SDKConfigurationKeys.ENABLE_OFFLINE_ACCESS);
        if(TextUtils.isEmpty(allowOffline)){
           return true; 
        }
        return Boolean.valueOf(allowOffline);
    }

    public boolean restrictDocumentToApps() throws AirWatchSDKException {
        return false;
    }

    public List<String> allowedApplications() throws AirWatchSDKException {
        return new ArrayList<String>();
    }

    // Custom settings

    public String getCustomSettings() throws AirWatchSDKException {
        return awSDKManager.getCustomSettings();
    }

    // Uncategorized

    public boolean isCompliant() throws AirWatchSDKException {
        return awSDKManager.isCompliant();
    }

    public boolean isCompromised() throws AirWatchSDKException {
        return awSDKManager.isCompromised();
    }

    public void openFile(Uri uri){
        UriOpenerFactory.getInstance().openUri(cordovaActivity, uri);
    }


}
