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
		
		function toggleFooter(element, visible) {
			var footer = document.getElementById(element.getAttribute("data-key") + "-footer");
			if (footer) {
			    footer.style.display = (visible ? "block" : "none");
			}
		}

		function hide(element) {
			element.style.opacity = 0;
			toggleFooter(element, false);
		}
		
		function show(element) {
			element.style.opacity = 1;
			toggleFooter(element, true);
		}
		
		out = {
			
			_current_screen : null,
			
			_screens : null,
			
			init : function() {
				
				this._screens = getDomScreens();
				
			},
			
			getAllScreens : function() {
				return this._screens;
			},
			
			getScreen : function(key) {
				return this._screens[key];
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
			},
			
			hideAllScreens : function() {
				
				var element = null;
				
				for(var i=0 in this._screens) {
					if(this._screens.hasOwnProperty(i)) {
						hide(this._screens[i]);
					}
				}
				
			},
			
			showScreen : function(key) {
				this.hideAllScreens();
				show(this._screens[key]);
			}
			
		}
		
		return out;
		
	})();
	
})();