module.exports = (server)->
  io = require('socket.io')(server)

  io.on 'connection', (socket)->
    console.log '11'
    socket.emit 'news', {
      hello: 'world'
    }
    socket.on 'my other event', (data)->
      console.log data