# Simple HTTP client to request backend easily.
window.client = {}
window.client.get = (url, callbacks) ->
    $.ajax
        type: 'GET'
        url: url
        success: (response) ->
            callbacks.success response
        error: (response) ->
            callbacks.error response

window.client.post = (url, data, callbacks) ->
    $.ajax
        type: 'POST'
        url: url
        data: JSON.stringify data
        dataType: "json"
        success: (response, pouet) ->
            callbacks.success response
        error: (response) ->
            callbacks.error response

