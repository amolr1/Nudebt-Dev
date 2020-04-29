window.globalInformation_onesignal = '';

window.gonative_onesignal_info = function(info){
    var oneSignal = JSON.stringify(info);
    alert('OneSignal Info:'+oneSignal);
    window.globalInformation_onesignal = JSON.parse(JSON.stringify(oneSignal));
}

window.gonative_status_beforelogin = function(data) {
    alert(JSON.stringify(data));    
    if (data && data.hasTouchId && data.hasSecret) {
        // Prompt the user to use the fingerprint to log in
        //window.location.href = 'gonative://auth/get?callbackFunction=gonative_secret_callback';
    }
}

