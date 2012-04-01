var CaptureStream = {    
    "startCapture" : function(success, failure, options) {
        return Cordova.exec(success, failure, "CaptureStream", "startCapture", [ options ]);
    },
    
    "capturePhoto" : function(success, fail) {
        return Cordova.exec(success, fail, "CaptureStream", "capturePhoto", []);
    },
    
    "endCapture" : function(success, fail) {
        return Cordova.exec(success, fail, "CaptureStream", "endCapture", []);
    }
};
