module.exports = class Feed

    db:       undefined
    feed:     undefined
    axonSock: undefined
    deleted_ids = {}

    constructor: ->
        @logger = require('printit')
            date: true
            prefix: 'helper/db_feed'

    initialize: (server) ->
        @startPublishingToAxon()

        server.on 'close', =>
            @stopListening()
            @axonSock.close()  if @axonSock?

    startPublishingToAxon: ->
        axon = require 'axon'
        @axonSock = axon.socket 'pub-emitter'
        axonPort =  parseInt process.env.AXON_PORT or 9105
        @axonSock.bind axonPort
        @logger.info 'Pub server started'

        @axonSock.sock.on 'connect', () =>
            @logger.info "An application connected to the change feeds"

    publish: (event, id) => @_publish(event, id)

    # [INTERNAL] publish to available outputs
    _publish: (event, id) ->
        @logger.info "Publishing #{event} #{id}"
        @axonSock.emit event, id if @axonSock?

module.exports = new Feed()
