Database = (@name, @version, @migrations) ->
  { Promise, indexedDB } = Database
  @open = new Promise (resolve, reject) ->
    request = indexedDB.open(name, version)
    request.addEventListener 'success', (event) => resolve(@db = event.target.result)
    request.addEventListener 'error', -> throw Error("Error opening database: #{@error.message}")
    request.addEventListener 'upgradeneeded', (event) =>
      { oldVersion, newVersion } = event
      migration.call(@) for migration in @migrations[oldVersion..newVersion]

Database.Promise = @Promise
Database.indexedDB = @indexedDB

Database.set = (settings = {}) -> Database[k] = v for own k, v of settings

if module?.exports?
  module.exports = Database
else
  @IndexTheBee = Database
count = (store) ->
  exec = (o, args...) ->
    args = keyRange(arg) for arg in args
    new Promise (resolve, reject) ->
      console.debug "count", store, o, args
      request = o.count(args...)
      request.addEventListener 'success', -> resolve(@result)
  f = ->
    exec(db.transaction(store).objectStore(store), args...)
  f.by = (index) ->
    g = ->
      exec(db.transaction(store).objectStore(store).index(index), args...)
    g.when = (args...) ->
      exec(db.transaction(store).objectStore(store).index(index), args...)
    g
  f
getAll = (store) ->
  exec = (o, args...) ->
    args = keyRange(arg) for arg in args
    new Promise (resolve, reject) ->
      result = []
      openDB.then (db) ->
        request = o.openCursor(args...)
        request.addEventListener 'success', ->
          return resolve(result) unless @result
          result.push @result.value
          @result.continue()
        request.addEventListener 'error', -> reject @error
  f = -> exec(db.transaction(store).objectStore(store))
  f.by = (index) ->
    g = ->
      exec(db.transaction(store).objectStore(store).index(index))
    g.when = (constraint) ->
      exec(db.transaction(store).objectStore(store).index(index), constraint)
    g
  f
get = (store) ->
  exec = (o, args...) ->
    new Promise (resolve, reject) ->
      openDB.then (db) ->
        request = o.get(args...)
        request.addEventListener 'success', -> resolve @result
        request.addEventListener 'error', -> reject @error
  f = -> exec(db.transaction(store).objectStore(store))
  f.by = (index) ->
    g = ->
      exec(db.transaction(store).objectStore(store).index(index))
    g.when = (constraint) ->
      constraint = IDBKeyRange.only(constraint) if constraint? and typeof constraint isnt 'object'
      exec(db.transaction(store).objectStore(store).index(index), constraint)
    g
  f

