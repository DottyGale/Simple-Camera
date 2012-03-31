var CaptureStream = {    
    "capture" : function(success, fail) {
        return Cordova.exec(success, fail, "CaptureStream", "capture", []);
    }
};
