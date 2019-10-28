/*
 * Copyright (c) 2017 AirWatch, LLC. All rights reserved.
 *  This product is protected by copyright and intellectual property laws in  the United States and other countries
 *  as well as by international treaties.
 *  AirWatch products may be covered by one or more patents listed at
 *  http://www.vmware.com/go/patents.
 */
package com.airwatch.cordova.sdkplugin;


import android.webkit.ClientCertRequest;
import android.webkit.HttpAuthHandler;
import android.webkit.WebView;

import com.airwatch.cordova.sdkplugin.commands.AllowCopyPasteCommand;
import com.airwatch.cordova.sdkplugin.commands.Command;
import com.airwatch.cordova.sdkplugin.commands.CustomSettingsCommand;
import com.airwatch.cordova.sdkplugin.commands.DLPFileOpenCommand;
import com.airwatch.cordova.sdkplugin.commands.GroupIdCommand;
import com.airwatch.cordova.sdkplugin.commands.ServerNameCommand;
import com.airwatch.cordova.sdkplugin.commands.UsernameCommand;
import com.airwatch.cordova.sdkplugin.commands.AllowOfflineCommand;
import com.airwatch.gateway.clients.AWWebViewDelegate;
import com.airwatch.sdk.AirWatchSDKException;
import com.airwatch.util.Logger;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;

import org.apache.cordova.*;
import org.apache.cordova.PluginResult.Status;
import org.json.*;

public class AirwatchSDKPlugin extends CordovaPlugin {

    public interface InitializationListener {
        void initSuccess();
        void initFailure();
    }
    
    public static final String LOG_TAG = AirwatchSDKPlugin.class.getSimpleName();

    private CallbackContext persistedContext;
    private AirwatchBridge bridge;
    private Map<String,Command> commandsMap=new HashMap<String, Command>();

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        bridge = AirwatchBridge.getInstance();
        initializeCommandMap();
    }

    private void initializeCommandMap(){
        commandsMap.put(Command.GROUP_ID,new GroupIdCommand());
        commandsMap.put(Command.USERNAME,new UsernameCommand());
        commandsMap.put(Command.SERVER_NAME,new ServerNameCommand());
        commandsMap.put(Command.ALLOW_COPY_PASTE,new AllowCopyPasteCommand());
        commandsMap.put(Command.CUSTOM_SETTINGS,new CustomSettingsCommand());
        commandsMap.put(Command.OPEN_FILE,new DLPFileOpenCommand());
        commandsMap.put(Command.ALLOW_OFFLINE,new AllowOfflineCommand());
    }

    private InitializationListener initListener = new InitializationListener() {
        @Override
        public void initSuccess() {
            sendEvent("initSuccess");
        }

        @Override
        public void initFailure() {
            sendEvent("initFailure");
        }
    };

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        Logger.w(LOG_TAG, "Entering execute(), action = " + action);

        if ("setPersistentCallback".equals(action)) {
            persistedContext = callbackContext;
            bridge.initAirwatchSDKManager(cordova.getActivity(), initListener);
            return true;
        }

        Command command = commandsMap.get(action);

        if(command == null) {
            return false;
        }
        try {
            command.execute(callbackContext,args,bridge);
        }catch (AirWatchSDKException e){
            sendError(callbackContext,e.toString());
        }
        return true;
    }

    private void sendError(CallbackContext callbackContext,String error) {
        callbackContext.sendPluginResult(new PluginResult(Status.ERROR,error));
    }

    public void sendEvent(String eventName) {
        sendEvent(eventName, null);
    }

    public void sendEvent(String eventName, JSONObject eventData) {
        if (persistedContext == null) {
            Logger.w(LOG_TAG, "No persistent context available, event '" + eventName + "' could not be sent to plugin");
            return;
        }
        PluginResult result = null;
        try {
            JSONObject event = new JSONObject();
            event.put("eventName", eventName);
            if (eventData != null) {
                event.put("eventData", eventData);
            }
            result = new PluginResult(Status.OK, event);
        } catch (JSONException je) {
            result = new PluginResult(Status.ERROR, "JSONException marshalling event data: " + je.getMessage());
        } finally {
            result.setKeepCallback(true);
            persistedContext.sendPluginResult(result);
        }
    }

    @Override
    public boolean onReceivedHttpAuthRequest(CordovaWebView view, ICordovaHttpAuthHandler handler, String host, String realm) {
        AWWebViewDelegate delegate=new AWWebViewDelegate();
        Class<?> c = handler.getClass();
        WebView webView=((AWCordovaActivity)cordova.getActivity()).getWebView();
        try {
            Field t = c.getDeclaredField("handler");
            t.setAccessible(true);
            Object o = t.get(handler);
            if(o instanceof HttpAuthHandler){
                delegate.onReceivedHttpAuthRequest(webView,(HttpAuthHandler)o,host,realm);
                return true;
            }

        }catch (NoSuchFieldException e){
            Logger.e(LOG_TAG,"Handler field not found.",e);
        }catch (IllegalAccessException e){
            Logger.e(LOG_TAG,"Handler field not accessible.",e);
        }

        return super.onReceivedHttpAuthRequest(view, handler, host, realm);
    }

    @Override
    public boolean onReceivedClientCertRequest(CordovaWebView view, ICordovaClientCertRequest request) {
        AWWebViewDelegate delegate=new AWWebViewDelegate();
        Class<?> c = request.getClass();
        WebView webView=((AWCordovaActivity)cordova.getActivity()).getWebView();
        try {
            Field t = c.getDeclaredField("request");
            t.setAccessible(true);
            Object o = t.get(request);
            if(o instanceof ClientCertRequest){
                delegate.onReceivedClientCertRequest(webView,(ClientCertRequest)o);
                return true;
            }

        }catch (NoSuchFieldException e){
            Logger.e(LOG_TAG,"ClientCertRequest field not found.", e);
        }catch (IllegalAccessException e){
            Logger.e(LOG_TAG,"ClientCertRequest field not accessible.", e);
        }
        return super.onReceivedClientCertRequest(view, request);
    }

}
