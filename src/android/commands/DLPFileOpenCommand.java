/*
 * Copyright (c) 2017 AirWatch, LLC. All rights reserved.
 *  This product is protected by copyright and intellectual property laws in  the United States and other countries
 *  as well as by international treaties.
 *  AirWatch products may be covered by one or more patents listed at
 *  http://www.vmware.com/go/patents.
 */
package com.airwatch.cordova.sdkplugin.commands;

import android.net.Uri;
import android.text.TextUtils;

import com.airwatch.cordova.sdkplugin.AirwatchBridge;
import com.airwatch.cordova.sdkplugin.AirwatchSDKPlugin;
import com.airwatch.sdk.AirWatchSDKException;
import com.airwatch.util.Logger;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

/**
 * Created by josephben on 6/7/17.
 */

public class DLPFileOpenCommand implements Command{
    public static int NO_ERROR=0;
    public static int PATH_NOT_SPECIFIED=1;
    @Override
    public void execute(CallbackContext callbackContext, JSONArray args, AirwatchBridge bridge) throws AirWatchSDKException {
        String fileUri;
        try{
            fileUri=args.getString(0);
            Uri uri=Uri.parse(fileUri);
            bridge.openFile(uri);
            if(TextUtils.isEmpty(fileUri)){
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, PATH_NOT_SPECIFIED));
                Logger.e(AirwatchSDKPlugin.LOG_TAG,"Path is empty");
            }
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, NO_ERROR));
        }catch (JSONException e){
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.JSON_EXCEPTION, PATH_NOT_SPECIFIED));
            Logger.e(AirwatchSDKPlugin.LOG_TAG,"Unable to obtain Uri for openFile "+e);
        }

    }
}
