({
	doInit : function(component, event, helper) {
		var opts = {
          angle: 0.07, // The span of the gauge arc
          lineWidth: 0.51, // The line thickness
          radiusScale: 1, // Relative radius
          pointer: {
            length: 0.5, // // Relative to gauge radius
            strokeWidth: 0.055, // The thickness
            color: '#000000' // Fill color
          },
          limitMax: false,     // If false, max value increases automatically if value > maxValue
          limitMin: false,     // If true, the min value of the gauge will be fixed
          colorStart: '#163BF2',   // Colors
          colorStop: '#101E57',    // just experiment with them
          strokeColor: '#E0E0E0',  // to see which ones work best for you
          generateGradient: true,
          highDpiSupport: true,     // High resolution support
          // renderTicks is Optional
          renderTicks: {
            divisions: 5,
            divWidth: 1.1,
            divLength: 0.7,
            divColor: '#333333',
            subDivisions: 3,
            subLength: 0.5,
            subWidth: 0.6,
            subColor: '#666666'
          }
        };
        var target = document.getElementById('gaugeMeter'); // your canvas element
        var gauge = new Gauge(target).setOptions(opts); // create sexy gauge!
        gauge.maxValue = 3000; // set max gauge value
        gauge.setMinValue(0);  // Prefer setter over gauge.minValue = 0
        gauge.animationSpeed = 67; // set animation speed (32 is default value)
        gauge.set(1650); // set actual value
   	}
})