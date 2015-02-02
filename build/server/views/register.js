var jade = require('jade/runtime');
module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
;var locals_for_with = (locals || {});(function (polyglot, timezones) {
buf.push("<!DOCTYPE html><html lang=\"en\"><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\"><title>" + (jade.escape((jade_interp = polyglot.t('register title')) == null ? '' : jade_interp)) + "</title><link rel=\"stylesheet\" href=\"/styles/app.css\"><link rel=\"icon\" type=\"image/x-icon\" href=\"/favicon.png\"></head><body><div id=\"content\"><div id=\"header\"><a id=\"logo\" href=\"http://cozy.io\"><img src=\"/images/happycloud.png\"><span>beta</span></a></div><div class=\"proxy-form register\"><h1>" + (jade.escape((jade_interp = polyglot.t('register headline')) == null ? '' : jade_interp)) + "</h1><h1>" + (jade.escape((jade_interp = polyglot.t('register informations')) == null ? '' : jade_interp)) + "</h1><h1>" + (jade.escape((jade_interp = polyglot.t('register instructions')) == null ? '' : jade_interp)) + "</h1><div class=\"input-wrapper\"><input id=\"email-input\" type=\"text\"" + (jade.attr("placeholder", "" + (polyglot.t('register email placeholder')) + "", true, true)) + "><span class=\"help\"><i class=\"icon\"></i><span class=\"help-info\"><div class=\"info\">" + (jade.escape((jade_interp = polyglot.t('register email info')) == null ? '' : jade_interp)) + "</div><div class=\"valid\">" + (jade.escape((jade_interp = polyglot.t('register email valid')) == null ? '' : jade_interp)) + "</div><div class=\"invalid\">" + (jade.escape((jade_interp = polyglot.t('register email invalid')) == null ? '' : jade_interp)) + "</div></span></span></div><div class=\"input-wrapper\"><input id=\"password-input\" type=\"password\"" + (jade.attr("placeholder", "" + (polyglot.t('register password placeholder')) + "", true, true)) + "><span class=\"help\"><i class=\"icon\"></i><span class=\"help-info\"><div class=\"info\">" + (jade.escape((jade_interp = polyglot.t('register password info')) == null ? '' : jade_interp)) + "</div><div class=\"valid\">" + (jade.escape((jade_interp = polyglot.t('register password valid')) == null ? '' : jade_interp)) + "</div><div class=\"invalid\">" + (jade.escape((jade_interp = polyglot.t('register password invalid')) == null ? '' : jade_interp)) + "</div></span></span></div><div class=\"input-wrapper\"><input id=\"password-check-input\" type=\"password\"" + (jade.attr("placeholder", "" + (polyglot.t('register check password placeholder')) + "", true, true)) + "><span class=\"help\"><i class=\"icon\"></i><span class=\"help-info\"><div class=\"info\">" + (jade.escape((jade_interp = polyglot.t('register check password info')) == null ? '' : jade_interp)) + "</div><div class=\"valid\">" + (jade.escape((jade_interp = polyglot.t('register check password valid')) == null ? '' : jade_interp)) + "</div><div class=\"invalid\">" + (jade.escape((jade_interp = polyglot.t('register check password invalid')) == null ? '' : jade_interp)) + "</div></span></span></div><div class=\"input-wrapper\"><input id=\"publicName-input\" type=\"text\"" + (jade.attr("placeholder", "" + (polyglot.t('register public name placeholder')) + "", true, true)) + "><span class=\"help\"><i class=\"icon\"></i><span class=\"help-info\"><div class=\"info\">" + (jade.escape((jade_interp = polyglot.t('register public name info')) == null ? '' : jade_interp)) + "</div></span></span></div><div class=\"input-wrapper\"><select id=\"timezone-input\">");
// iterate timezones
;(function(){
  var $$obj = timezones;
  if ('number' == typeof $$obj.length) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var timezone = $$obj[$index];

if ( timezone === "GMT")
{
buf.push("<option" + (jade.attr("value", "" + (timezone) + "", true, true)) + " selected=\"selected\">" + (jade.escape(null == (jade_interp = timezone) ? "" : jade_interp)) + "</option>");
}
else
{
buf.push("<option" + (jade.attr("value", "" + (timezone) + "", true, true)) + ">" + (jade.escape(null == (jade_interp = timezone) ? "" : jade_interp)) + "</option>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj) {
      $$l++;      var timezone = $$obj[$index];

if ( timezone === "GMT")
{
buf.push("<option" + (jade.attr("value", "" + (timezone) + "", true, true)) + " selected=\"selected\">" + (jade.escape(null == (jade_interp = timezone) ? "" : jade_interp)) + "</option>");
}
else
{
buf.push("<option" + (jade.attr("value", "" + (timezone) + "", true, true)) + ">" + (jade.escape(null == (jade_interp = timezone) ? "" : jade_interp)) + "</option>");
}
    }

  }
}).call(this);

buf.push("</select><span class=\"help\"><i class=\"icon\"></i><span class=\"help-info\"><div class=\"info\">" + (jade.escape((jade_interp = polyglot.t('register timezone info')) == null ? '' : jade_interp)) + "</div></span></span></div><input id=\"locale-input\" type=\"hidden\"" + (jade.attr("value", "" + (polyglot.currentLocale) + "", true, true)) + "><p id=\"reinsurance\">" + (jade.escape((jade_interp = polyglot.t('register reinsurance modification')) == null ? '' : jade_interp)) + "<br>" + (jade.escape((jade_interp = polyglot.t('register reinsurance share')) == null ? '' : jade_interp)) + "</p><div id=\"btn-wrapper\"><div class=\"btn-container center\"><a id=\"expand-btn\">" + (jade.escape((jade_interp = polyglot.t('register button moreinfo')) == null ? '' : jade_interp)) + "</a></div><div id=\"btn-separator\">" + (jade.escape((jade_interp = polyglot.t('register button separator')) == null ? '' : jade_interp)) + "</div><div class=\"btn-container right single\"><button id=\"submit-btn\" disabled=\"disabled\">" + (jade.escape((jade_interp = polyglot.t('register button')) == null ? '' : jade_interp)) + "</button></div></div><div class=\"alert-error\">&nbsp;</div><div class=\"alert-success\">" + (jade.escape((jade_interp = polyglot.t('register success message')) == null ? '' : jade_interp)) + "</div></div></div><script src=\"/scripts/app.js\"></script><script>require('client');</script><script>require('register');\nvar REGISTER_BUTTON = \"" + (jade.escape((jade_interp = polyglot.t('register button')) == null ? '' : jade_interp)) + "\";\n</script></body></html>");}.call(this,"polyglot" in locals_for_with?locals_for_with.polyglot:typeof polyglot!=="undefined"?polyglot:undefined,"timezones" in locals_for_with?locals_for_with.timezones:typeof timezones!=="undefined"?timezones:undefined));;return buf.join("");
}