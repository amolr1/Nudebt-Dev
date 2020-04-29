window.globalInformation_onesignal = '';

window.setTimeout(function() {
    if (navigator.userAgent.indexOf('gonative') > -1) {
		window.location.href = 'gonative://run/gonative_onesignal_info';
	}
}, 5000);

window.gonative_onesignal_info = function(info) {
    var oneSignal = JSON.stringify(info);
    window.globalInformation_onesignal = JSON.parse(JSON.stringify(oneSignal));
}