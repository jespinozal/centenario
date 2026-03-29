({
	renderGauge : function(cmp, evt) {
        var chc = cmp.get("v.chc");
        var opts = {
            angle: 0, // The span of the gauge arc
            lineWidth: cmp.get("v.GaugeLineWidth"), // The line thickness
            radiusScale: 1, // Relative radius
            pointer: {
                length: 0.6, // // Relative to gauge radius
                strokeWidth: 0, // The thickness
                color: '#000000' // Fill color
            },
            limitMax: false,     // If false, max value increases automatically if value > maxValue
            limitMin: false,     // If true, the min value of the gauge will be fixed
            colorStart: '#6FADCF',   // Colors
            colorStop: '#8FC0DA',    // just experiment with them
            strokeColor: '#E0E0E0',  // to see which ones work best for you
            generateGradient: true,
            highDpiSupport: true,     // High resolution support
            percentColors: [[0.0, "#d4351f" ], [0.20, "#e17026"], [0.40, "#f4c430"], 
                            [0.60, "#a9d621"], [0.80, "#66d853"]
                           ],
        };
        var CSATDivId = cmp.get("v.CleanGID")+"CSAT";
        var CSATTextId = cmp.get("v.CleanGID")+"CSAT-textfield";
        var targetCSAT = document.getElementById(CSATDivId); // your canvas element
        if (targetCSAT != null) {
            var gaugeCSAT = new Gauge(targetCSAT).setOptions(opts); // create sexy gauge!
            gaugeCSAT.maxValue = 5; // set max gauge value
            gaugeCSAT.setMinValue(0);  // Prefer setter over gauge.minValue = 0
            gaugeCSAT.animationSpeed = 32; // set animation speed (32 is default value)
            gaugeCSAT.set(cmp.get("v.chc").CSAT); // set actual value
            //gaugeCSAT.set(4); // set actual value
            //gaugeCSAT.setTextField(document.getElementById(CSATTextId));
        }
        
        var NPSDivId = cmp.get("v.CleanGID")+"NPS";
        var NPSTextId = cmp.get("v.CleanGID")+"NPS-textfield";
        var targetNPS = document.getElementById(NPSDivId); // your canvas element
        if (targetNPS != null) {
            var gaugeNPS = new Gauge(targetNPS).setOptions(opts); // create sexy gauge!
            gaugeNPS.maxValue = 150; // set max gauge value
            gaugeNPS.setMinValue(-150);  // Prefer setter over gauge.minValue = 0
            gaugeNPS.animationSpeed = 12; // set animation speed (32 is default value)
            gaugeNPS.set(cmp.get("v.chc").NPS); // set actual value
            gaugeNPS.setTextField(document.getElementById(NPSTextId));
        }
        
        var miles=cmp.get("v.chc.Contact.Miles__c");
        var flights=cmp.get("v.chc.Contact.Flights__c");
        var tier=cmp.get("v.chc.Contact.Level__c");
       	var milespercent=miles;
        var flightspercent=flights;
        
        if (tier == "Silver"){
            milespercent=Math.trunc((miles*100)/40000); 
            flightspercent=Math.trunc((flights*100)/20); 
        }else{
        if (tier == "Gold"){
            milespercent=Math.trunc((miles*100)/80000);
            flightspercent=Math.trunc((flights*100)/35); 
        }else{
            milespercent=Math.trunc((miles*100)/150000);  
            flightspercent=Math.trunc((flights*100)/50); 
        }}
        
        cmp.set("v.LoyaltyProgressMiles",milespercent);
        cmp.set("v.LoyaltyProgressFlights",flightspercent);
    },
    
    //Lurdes
    readFile: function(component, helper, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
  			return alert('Image file not supported');
		}
        var reader = new FileReader();
        reader.onloadend = function() {
            var dataURL = reader.result;
            console.log(dataURL);
            component.set("v.imagenSrc", dataURL);
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1]);
        };
        reader.readAsDataURL(file);
	},
    
    upload: function(component, file, base64Data) {
        var action = component.get("c.saveAttachment"); 
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: base64Data, 
            contentType: file.type
        });
        action.setCallback(this, function(a) {
            component.set("v.message", "Image uploaded");
        });
        component.set("v.message", "Uploading...");
        $A.enqueueAction(action); 
    }
})