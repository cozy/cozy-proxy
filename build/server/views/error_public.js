var jade = require('jade/runtime');
module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
;var locals_for_with = (locals || {});(function (polyglot) {
buf.push("<!DOCTYPE html><html lang=\"en\"><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\"><title>" + (jade.escape((jade_interp = polyglot.t('error title')) == null ? '' : jade_interp)) + "</title><link rel=\"stylesheet\" href=\"/styles/app.css\"><link rel=\"icon\" type=\"image/x-icon\" href=\"/favicon.png\"></head><body><div id=\"content\"><div id=\"header\"><a id=\"logo\" href=\"http://cozy.io\"><img src=\"/images/happycloud.png\"><span>beta</span></a></div><div class=\"proxy-form error\"><h1> " + (jade.escape((jade_interp = polyglot.t('error headline')) == null ? '' : jade_interp)) + "</h1><p>" + (jade.escape((jade_interp = polyglot.t('error reinsurance')) == null ? '' : jade_interp)) + "<br>" + (jade.escape((jade_interp = polyglot.t('error public info')) == null ? '' : jade_interp)) + "</p></div></div><script src=\"/scripts/app.js\"></script><script>require('client');</script></body></html>");}.call(this,"polyglot" in locals_for_with?locals_for_with.polyglot:typeof polyglot!=="undefined"?polyglot:undefined));;return buf.join("");
}