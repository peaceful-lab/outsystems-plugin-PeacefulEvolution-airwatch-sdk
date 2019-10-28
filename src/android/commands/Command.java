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
import org.json.JSONArray;

/**
 * Created by josephben on 1/30/2017.
 */

public interface Command {

    String GROUP_ID="groupId";
    String USERNAME="username";
    String CUSTOM_SETTINGS="customSettings";
    String SERVER_NAME="serverName";
    String ALLOW_COPY_PASTE="allowCopyPaste";
    String OPEN_FILE="openFile";
    String ALLOW_OFFLINE="allowOffline";

    void execute(CallbackContext callbackContext, JSONArray args, AirwatchBridge bridge) throws AirWatchSDKException;
}
