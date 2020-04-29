window._counter = (function() {

    return { //public API
        
        getValue: function() {
			var oneSignal = 'Hi';
			
			window.gonative_onesignal_info = function(info){
				oneSignal = JSON.stringify(info);
			}
            return oneSignal;
        }
    };
}());