//jQuery Regressive Timer
//By Rodrigo Dlugokenski <github.com/rodrigodk>
//Heavily Based on David Walsh work - Kudos to him
//http://davidwalsh.name/jquery-countdown-plugin
//Demo: http://jsfiddle.net/rodrigodk/x5J4B

//Define the Extension
jQuery.fn.regressiveTimer = function (settings, to) {
    settings = jQuery.extend({
        duration: 1000,
        startDate: moment(),
        endDate: moment().add('m', 5),
        language: 'pt-br',
        callBack: function () {}
    }, settings);
    return this.each(function () {
        //where do we start?
        if (!to && to != 0) {
            to = settings.endDate - settings.startDate;
        }

        //set the countdown to the starting number
        jQuery(this).text(moment.duration(to).lang(settings.language).humanize(true));

        //loopage
        var $this = jQuery(this);
        //console.log(to);
        setTimeout(function () {
            if (to > 1) {
                to = to - settings.duration;
                $this.text(moment.duration(to).lang(settings.language).humanize(true)).regressiveTimer(settings, to);
            } else {
                settings.callBack($this);
            }
        }, settings.duration);

    });
};