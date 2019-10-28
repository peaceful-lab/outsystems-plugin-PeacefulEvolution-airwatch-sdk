airwatch-sdk-plugin
===================

Use this document to install the VMware AirWatch SDK Plugin for Apache Cordova. The plugin helps enterprise app developers add enterprise- grade security, conditional access, and compliance capabilities to mobile applications.

Supported Components
--------------------

This plugin works with the listed component versions.
* Workspace ONE UEM console v9.1+ 
* Android v5.0+
* iOS 10.0+

Installation
------------

To install the plugin, type `cordova plugin add airwatch-sdk-plugin` at the command line. This should be added before any other plugin is added to the app.
**Note:** The download from NPM, usually takes 2-3 minutes on average, over high speed internet connection. While installing the plugin, if below error is encountered, run `npm install q glob ` .

*Failed to install ‘airwatch-sdk-plugin’: Error: Cannot find module ‘q’*

Initialization
--------------

The plugin auto-starts on both Android and iOS devices and it automatically starts the AirWatch SDK. After startup, the functions are available in the **window.plugins.airwatch** object. No other initialization is required to use the documented functions.

To receive events from the SDK, an event listener must be initialized. See "Events" below.

Initialization of the SDK adds the listed features to your application, depending on the configurations set in the SDK profile in the AirWatch Console.
* Application level passcode
* Application level tunneling of network traffic 
* Integrated authentication / single sign on 
* Data loss prevention
    * Disable screenshot (Android only)
    * Restrict open-in for documents, web links, and email to approved applications only Restrict copy/paste (SDK provides flag value)
    * Restrict access to app when device is offline
* Branding of VMware AirWatch splash screens when SDK application is launched on device

Functions
---------
<dl>

### Functions available for Android and iOS

<dt><code>setSDKEventListener(listener)</code></dt>
<dd style="padding-bottom: 8pt">Sets an event-handler function to receive events from the SDK. See the "Events" section. This should be called once Cordova fires 'deviceready' event. The listener callback should have two parameters, event and info.</dd>

<dt><code>username(successCallback, errorCallback)</code></dt>
<dd style="padding-bottom: 8pt">Gets the enrolled user's username. The username is returned as a string parameter to the successCallback function.</dd>

<dt><code>groupId(successCallback, errorCallback)</code></dt>
<dd style="padding-bottom: 8pt">Gets the enrolled user's group ID. The group ID will be returned as a string parameter to the successCallback function.</dd>

<dt><code>serverName(successCallback, errorCallback)</code></dt>
<dd style="padding-bottom: 8pt">Get the name of the server to which the device is enrolled. The server name will be returned as a string parameter to the successCallback function.</dd>

<dt><code>allowCopyPaste(successCallback, errorCallback)</code></dt>
<dd style="padding-bottom: 8pt">Gets the "allow copy/paste" setting for the profile. If true, then the user can copy and paste between managed apps. If false then the user cannot copy and paste between managed apps. The value is returned as a boolean parameter to the successCallback function.</dd>

<dt><code>customSettings(successCallback, errorCallback)</code></dt>
<dd style="padding-bottom: 8pt">Gets any custom settings provided in the app's profile. The value will be returned as a string parameter to the successCallback function.</dd>

<dt><code>allowOffline(successCallback, errorCallback)</code></dt>
<dd style="padding-bottom: 8pt">Gets the "allow offline use" setting for the profile. If true, then the user can use managed apps when not connected to the network. If false, the user cannot use managed apps when not connected to the network. The value is returned as a boolean parameter to the successCallback function. </dd>

<dt><code>openFile (absolutepath, successCallback, errorCallback)</code></dt>
<dd style="padding-bottom: 8pt">Opens the file specified by the absolute path in accordance with the data loss prevention settings as configured on the AirWatch Console. The plugin restricts the files only to those whitelisted applications. Applications can have a custom implementation using restrictDocumentToApps and allowedApplications APIs. A success callback is invoked when the plugin is successfully able to open the file. In all other cases, an error callback is invoked with the corresponding error code.

To obtain the absolute path of the file (whether the file available bundled in the app or downloaded to the documents folder by the app), refer to the Cordova File plugin documentation, at <https://cordova.apache.org/docs/en/latest/reference/cordova-plugin-file/>.

Error code values for openFile
* 2 - File not found at the path 
* 1 - Absolute path not specified 
* 0 - No error
</dd>

Events
------
The AirWatch SDK sends event notifications to applications that use it when certain conditions arise. To receive these notifications in a Cordova app, call `setSDKEventListener(listener)`. The `listener` is a function that accepts two parameters. The first parameter will be a string containing the name of the event, as listed below. The second is an object that contains additional data if relevant to that type of event.

<dl>

### Events available for Android and iOS

<dt><code>initSuccess</code></dt>
<dd style="padding-bottom: 8pt">Sent when the AirWatch SDK is successfully initialized. All the functions of the plugin, other than <code>setSDKEventListener(listener)</code>, are available after this event is fired. See 'Functions' section above. </dd>

<dt><code>initFailure</code></dt>
<dd style="padding-bottom: 8pt">Sent when the AirWatch SDK cannot be successfully initialized. Any future calls to the plugin fails.</dd>

### Events available for iOS only

<dt><code>wipe</code></dt>
<dd style="padding-bottom: 8pt">Sent when the device receives a "wipe" instruction from the console.</dd>

<dt><code>lock</code></dt>
<dd style="padding-bottom: 8pt">Sent when the device receives a "lock" instruction from the console.</dd>

<dt><code>unlock</code></dt>
<dd style="padding-bottom: 8pt">Sent when the device receives an "unlock" instruction from the console.</dd>

<dt><code>stopNetworkActivity</code></dt>
<dd style="padding-bottom: 8pt">Sent when the device receives a "stopNetworkActivity" instruction from the console. The event data parameter contains a property named <code>status</code> with a numeric value as specified in the table below.</dd>

<dt><code>resumeNetworkActivity</code></dt>
<dd style="padding-bottom: 8pt">Sent when the device receives a "resumeNetworkActivity" instruction from the console.</dd>

</dl>

### Network status values for `stopNetworkActivity`:

Status code | Network state
:----------:|:-------------
 -2         | initializing
 -1         | normal
  1         | cellular data disabled
  2         | roaming
  3         | proxy failed
  4         | network not reachable

Best Practices
--------------

### Add Business Logic After the initSuccess Event Fires

For applications using the AirWatch SDK, have all business logic of the application added after the SDK fires initSuccess event. This means the SDK successfully initialized and the user is authenticated successfully, if applicable.

The application waits until the initSuccess or initFailure event fires. Until the AirWatch SDK completely loads and the initSuccess event fires, the application shows a waiting screen or a loading screen to give feedback to the user that the applicaiton is in the process of loading and starting.

### Do Not Add Business Logic to the deviceready Event

Unless there is a specific business requirement to perform operations before the AirWatch SDK is initialized, do not add logic to the deviceready event. The SDK shows an authentication screen above Cordova WebView which can block the application's UI until the SDK is initialized. The initFailure event fires when if SDK initialization somehow fails. The application listens to this event and shows the corresponding error in the application.

### Quick Example

On deviceready, please set the SDK event listener: `window.plugins.airwatch.setSDKEventListener(sdkEventCallback)` . The sdkEventCallback is a function that takes two arguments:
1. A string that holds the name of the event fired.
2. An object that contains the additional info on the event function sdkEventCallback(event, info).

```
function sdkEventCallback(event, info)
{
    /* Check (event === "initSuccess") before using sdk functionalities */
}
```

AirWatch SDK Documentation
--------------------------
For further details about the AirWatch SDK, navigate to <https://my.workspaceone.com/products/Workspace-ONE-SDK> and select the required platform, SDK version and Workspace ONE UEM console version.


Open Source Link
--------------------------
<https://www.air-watch.com/downloads/open_source_license_AirWatch_SDK_Cordova_Plugin_1.4_GA.txt>

Questions and Feedback
----------------------
For any questions/feedback or to report an issue, please reach out to VMware support teams at <https://secure.workspaceone.com/login>
