var fadeSlide;

fadeSlide = function(obj, text, callback) {
var c, _i, _len, _results;
obj.html('');
recFade = function(i) {
   if(i >= text.length) {
       callback();
   } else {
     c = text[i];
     obj.append("<span>" + c + "</span>");
     $(obj.find("span").get(i)).hide();
     $(obj.find("span").get(i)).fadeIn(2000);
     i++;
     recFade(i);
  };
};
recFade(0);
};

