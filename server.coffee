'use strict'

DIR = '.'

http    = require 'http'
fs      = require 'fs'
path    = require 'path'
mime    = require 'mime'
pug     = require 'pug'
stylus  = require 'stylus'
coffee  = require 'coffee-script'

# Compiles a coffee-script buffer to javascript, and returns the right content
# type.
compileCoffee = ({ data, filename }) ->
  contentType = 'application/javascript'
  data = coffee.compile(new Buffer(data).toString('utf8'), { filename })
  { data, contentType, filename }

# Compiles a pug buffer to HTML and returns the right content type.
compilePug = ({ data, filename }) ->
  contentType = 'text/html'
  data = pug.render(new Buffer(data).toString('utf8'), { filename })
  { data, contentType, filename }

# Compiles a Stylus buffer to CSS and returns a promise which resolves to the
# compiled CSS and the right content type.
compileStylus = ({ data, filename }) ->
  contentType = 'text/css'
  src = new Buffer(data).toString('utf8')
  new Promise (resolve, reject) ->
    stylus.render src, { filename }, (err, css) ->
      return reject(err) if err?
      data = css
      resolve { data, contentType, filename }

# Reads a file relative to DIR, and resolves to the file's data and content
# type. If it's a directory, it tries 'index.html' within that directory. If
# it's '.html' and not found, it tries to compile a .pug file. If it's '.js'
# and not found, it tries to comile a .coffee file. If it's .css and not
# found, it tries to compile a .styl file.
readFile = (filename) ->
  new Promise (resolve, reject) ->
    fs.readFile filename, (err, data) ->
      switch err?.code
        when 'EISDIR'
          readFile(path.join(filename, 'index.html')).then(resolve, reject)
        when 'ENOENT'
          if path.extname(filename) is '.js'
            filename = filename.replace(/\.js$/, '.coffee')
            readFile(filename).then(compileCoffee).then(resolve, reject)
          else if path.extname(filename) is '.html'
            filename = filename.replace(/\.html/, '.pug')
            readFile(filename).then(compilePug).then(resolve, reject)
          else if path.extname(filename) is '.css'
            filename = filename.replace(/\.css$/, '.styl')
            readFile(filename).then(compileStylus).then(resolve, reject)
          else
            reject(err)
        when undefined
          contentType = mime.lookup(filename)
          resolve({ data, contentType, filename })
        else
          resolve(err)

writeResponse = (response) ->
  ({ data, contentType, filename, err }) ->
    new Promise (resolve, reject) ->
      response.statusCode = 200
      response.setHeader('Content-Type', contentType)
      response.write data, -> response.end()
      console.log(timestamp(), response.statusCode, response.statusMessage, filename)

writeError = (response) ->
  (err) ->
    switch err.code
      when 'ENOENT'
        response.statusCode = 404
        response.statusMessage = 'Not found'
      else
        response.statusCode = 500
        response.statusMessage = 'Internal server error'
        console.error('!', err)
    response.end()
    console.log(timestamp(), response.statusCode, response.statusMessage)

timestamp = -> new Date().toISOString()

handler = (request, response) ->
  { method, headers, url } = request
  console.log(timestamp(), request.method, request.url)
  readFile(path.normalize(path.join(DIR, url)))
    .then   writeResponse(response)
    .catch  writeError(response)

http.createServer(handler).listen (process.env.PORT ? 8800), ->
  { address, port } = @address()
  { name, version } = require('./package')
  console.log "#{name} v#{version} listening on #{address}:#{port}"
  console.log 'Kill with Ctrl-C.'
