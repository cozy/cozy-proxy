
(function($,window,undefined){

  $.fn.spin = function(doSpin) {
    if(doSpin){
      this.width(this.width());
      this.height(this.height());
      this.data('spinner-content-was', this.contents());
      spinWhite = !this.hasClass('spin-black');
      this.html('<div class="spinholder">' +
        '<img src="/images/spinner' + (spinWhite ? '-white': '') + '.svg" />' +
        '</div>');
    }else{
      this.css({width: '', height: ''});
      this.empty().append(this.data('spinner-content-was'));
    }
    return this;
  };

})(jQuery,this);
