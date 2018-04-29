"use strict";
/* globals MultiBox,ALTUI_PluginDisplays,_T */

var Pioneer_Displays= ( function( window, undefined ) {

	function _drawPioneer( device ) {
		var html ="";
		var level = parseInt(MultiBox.getStatus( device, 'urn:upnp-org:serviceId:RenderingControl1', 'Volume' ));
		var status = parseInt(MultiBox.getStatus( device, 'urn:upnp-org:serviceId:SwitchPower1', 'Status' ));
		html += ALTUI_PluginDisplays.createOnOffButton( status,"altui-onoffbtn-"+device.altuiid, _T("OFF,ON") , "pull-right");

		html += ("<span id='slider-val-"+device.altuiid+"' class='altui-dimmable' >"+level+"% </span>");
		html += ("<div id='slider-{0}' class='altui-dimmable-slider' ></div>").format(device.altuiid);

		html += "<script type='text/javascript'>";
		html += " $('div#altui-onoffbtn-{0}').on('click', function() { ALTUI_PluginDisplays.toggleOnOffButton('{0}','div#altui-onoffbtn-{0}'); } );".format(device.altuiid);
		html += "$('div#slider-{0}.altui-dimmable-slider').slider({ max:100,min:0,value:{1},change:ALTUI_PluginDisplays.onSliderChange });".format(device.altuiid,level);
		html += "</script>";
		$(".altui-mainpanel").off("slide","#slider-"+device.altuiid).on("slide","#slider-"+device.altuiid,function( event, ui ){
			$("#slider-val-"+device.altuiid).text( ui.value+'%');
		});
		return html;
                }
    return {
        /* exports */
        drawPioneer: _drawPioneer
	toggleOnOffButton : function (altuiid,htmlid) {
		ALTUI_PluginDisplays.toggleButton(altuiid, htmlid, 'urn:upnp-org:serviceId:SwitchPower1', 'Status', function(id,newval) {
			MultiBox.setOnOff( altuiid, newval);
		});
    };
})( window );
