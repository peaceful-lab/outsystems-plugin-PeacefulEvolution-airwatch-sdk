/*
 * Copyright (c) 2017 AirWatch, LLC. All rights reserved.
 *  This product is protected by copyright and intellectual property laws in  the United States and other countries
 *  as well as by international treaties.
 *  AirWatch products may be covered by one or more patents listed at
 *  http://www.vmware.com/go/patents.
 */
package com.airwatch.cordova.sdkplugin;

import android.content.Intent;
import android.support.annotation.Nullable;
import com.airwatch.gateway.ui.GatewaySplashActivity;
import android.support.v4.app.NotificationCompat;
import com.airwatch.util.Logger;
import java.security.cert.X509Certificate;
import com.airwatch.app.AWApplication;
/**
 * Created by josephben on 12/19/2016.
 */

public class AWCordovaApplication extends AWApplication {
    
    private static final String TAG = AWCordovaApplication.class.getSimpleName();
   @Override
	public Intent getMainActivityIntent() {
		return new Intent(getApplicationContext(), AWCordovaActivity.class);
	}

    @Override public Intent getMainLauncherIntent() {
        return new Intent(getApplicationContext(), GatewaySplashActivity.class);
    }

    @Override
    public boolean getIsStandAloneAllowed() {
        return false;
    }

    @Override public boolean isInputLogoBrandable() {
		return true;
	}
    @Override
    public void onSSLPinningValidationFailure(String host, @Nullable X509Certificate serverCACert) {
        Logger.v(TAG, "SSLPinning validation failed for host: "+host);
    }
    
    @Override
    public void onSSLPinningRequestFailure(String host, @Nullable X509Certificate serverCACert) {
        Logger.v(TAG, "SSLPinning request failed for host: "+host);
    }
}
