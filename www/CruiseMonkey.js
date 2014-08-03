/***
 * CruiseMonkey plugin.
 * @author <cruisemonkey@raccoonfink.com>
*/
var exec = require("cordova/exec");
module.exports = {
    /**
    * @property {Boolean} flag to determine if a current fetch operation is active
    */
    isActive: false,

    configure: function(callback, failure, config) {
        var me = this;
        // wrap the supplied callback so we can set isActive flag.
        var success = function() {
            me.isActive = true;
            callback.apply(me, arguments);    
        };
        exec(success || function() {},
             failure || function() {},
             'CruiseMonkey',
             'configure',
             []);
    },
    start: function(success, failure, config) {
        // No implementation necessary for ios
    },
    stop: function(success, failure, config) {
        // No implementation necessary for ios
    },
    getStatus: function() {
        // No implementation necessary for ios
    },
    finish: function(success, failure) {
        exec(success || function(){},
            failure || function(){},
            'CruiseMonkey',
            'finish',
            []);
        this.isActive = false;
    }
};

