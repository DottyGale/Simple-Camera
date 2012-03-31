var CaptureStream = {    
    "startCapture" : function(success, fail) {
        return Cordova.exec(success, fail, "CaptureStream", "startCapture", []);
    },
    
    "capturePhoto" : function(success, fail) {
        return Cordova.exec(success, fail, "CaptureStream", "capturePhoto", []);
    },
    
    "endCapture" : function(success, fail) {
        return Cordova.exec(success, fail, "CaptureStream", "endCapture", []);
    }
};
