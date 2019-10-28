/*
 * Copyright (c) 2017 AirWatch, LLC. All rights reserved.
 *  This product is protected by copyright and intellectual property laws in  the United States and other countries
 *  as well as by international treaties.
 *  AirWatch products may be covered by one or more patents listed at
 *  http://www.vmware.com/go/patents.
 */
package com.airwatch.cordova.sdkplugin.commands;

import com.airwatch.cordova.sdkplugin.AirwatchBridge;
import com.airwatch.sdk.AirWatchSDKException;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;

/**
 * Created by josephben on 1/31/2017.
 */

public class ServerNameCommand implements Command {
    @Override
    public void execute(CallbackContext callbackContext, JSONArray args, AirwatchBridge bridge) throws AirWatchSDKException {
        String result=bridge.getServerName();
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, result));
    }
}
