//= require active_admin/base
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jcrop

$(function() {
  var urlSearchParams = discoverParams();
  
  $('#slider').slider({
		min: 0,
		max: 100,
    value: urlSearchParams["density"] || 50,
		step: 1,
		change: function( event, ui ) {
		  window.location.search = "density=" + ui.value;
		}
  });
  
  $('#size-slider').slider({
		min: 0,
		max: 200,
    value: 100,
		change: function( event, ui ) {
		  var dimension = 400 * ui.value / 100 + 'px';
		  $("#blend_image").css({'height': dimension, 'width': dimension});
		}
  });
  
  $('#cropbox').Jcrop({
    onChange: updateCrop,
    onSelect: updateCrop,
    setSelect: [200, 100, 500, 300],
    aspectRatio: 1
  });
});

function updateCrop(coords) {
  var ratio = $("#cropbox").data("ratio");
  $("#image_crop_x").val(Math.round(coords.x * ratio));
  $("#image_crop_y").val(Math.round(coords.y * ratio));
  $("#image_crop_w").val(Math.round(coords.w * ratio));
  $("#image_crop_h").val(Math.round(coords.h * ratio));
}

function discoverParams() {
  var search = window.location.search.substring(window.location.search[0] == "?" ? 1 : 0);
  var params = {};
  var paramsArray = search.split("&");
  for (var i=0; i < paramsArray.length; i++) {
    param = paramsArray[i].split("=");
    params[param[0]] = param[1];
  };
  return params;
}