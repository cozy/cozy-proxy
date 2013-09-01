wait = (time, callback) ->
    setTimeout callback, time

progFadeIn = (objs, callback) ->
    if objs.length is 1
        obj = objs.shift()
        obj.fadeIn 800, callback
    else if objs.length > 0
        obj = objs.shift()
        obj.fadeIn 800
        wait 100, ->
            progFadeIn objs, callback

progFadeOut = (objs, callback) ->
    if objs.length is 1
        obj = objs.pop()
        console.log callback
        obj.fadeOut 800, callback
    if objs.length > 0
        obj = objs.pop()
        obj.fadeOut 800
        wait 100, ->
            progFadeOut objs, callback
