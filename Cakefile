task "test:server", "start a test server for mocha tests", ->
  coffee = (f, cb) ->
    { readFile } = require 'fs'
    { compile } = require 'coffee-script'
    readFile f, 'utf8', (err, data) ->
      throw err if err?
      cb(compile(data))
  express = require 'express'
  app = express()
  app.set 'views', 'test'
  app.set 'view engine', 'jade'
  app.get '/', (req, res) -> res.render('index')
  app.get '/indexTheBee.js', (req, res) -> coffee("indexTheBee.coffee", ((js)-> res.end(js)))
  app.get '/indexTheBee.tests.js', (req, res) -> coffee("test/indexTheBee.coffee", ((js)-> res.end(js)))
  app.get '/tests.js', (req, res) -> coffee("test/indexTheBee.coffee", ((js)-> res.end(js)))

  app.use express.static('test')
  app.use express.static('node_modules/mocha')
  app.use express.static('node_modules/chai')
  app.listen process.env.PORT or 9933, ->
    { name, version } = require './package'
    { address, port } = @address()
    console.log "#{name} v#{version} test server listening on #{address}:#{port}"
