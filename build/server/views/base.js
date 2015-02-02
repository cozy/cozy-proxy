var jade = require('jade/runtime');
module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<!DOCTYPE html><html lang=\"en\"><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\"><link rel=\"stylesheet\" href=\"/styles/app.css\"><link rel=\"icon\" type=\"image/x-icon\" href=\"/favicon.png\"></head><body><div id=\"content\"><div id=\"header\"><a id=\"logo\" href=\"http://cozy.io\"><img src=\"/images/happycloud.png\"><span>beta</span></a></div></div><script src=\"/scripts/app.js\"></script><script>require('client');</script></body></html>");;return buf.join("");
}