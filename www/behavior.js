(function() {
	
	/*
	*  Simple camera behavior
	*/
	
	window.SCA = {}; //Simple Camera App
	
	var SCREENS_SELECTOR = '.simple-camera div.content section';
	
	window.SCA = (function() {
		
		var out = null;
		
		function getDomScreens() {
			
			var elements  = document.querySelectorAll(SCREENS_SELECTOR),
			    map       = {};
			
			for(var i=0, l=elements.length; l > i; i++) {
				var element = elements[i];
				map[element.dataset['key'] || i] = element;
			}
			
			return map;
			
		}   
		
		out = {
			
			_screens : null,
			
			init : function() {
				
				this._screens = getDOMScreens();
				
			},
			
			getAllScreens : function() {
				return this._screens;
			},
			
			removeScreen : function(key) {
				var element = null;
				
				for(var i=0 in this._screens) {
					if(this._screens.hasOwnProperty(i) && i===key) {
						element = this._screens[i];
						element.parentNode.removeChild(element);
						delete this._screens[i];
						
						return !this._screens[i];
					}
				}
				
				return false;
			},
			
			appendScreen : function(key, element) {
				this._screens[key] === element;
			}
			
		}
		
		return out;
		
	})();
	
})();