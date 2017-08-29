'use strict'

{ indexedDB, Promise, console } = @

Store = (db, storeName) ->
  @indexNames = db.transaction(storeName).objectStore(storeName).indexNames
  @[indexName] = new Index(@, indexName) for indexName in @indexNames

Database = (db) ->
  { @name, @version, objectStoreNames } = db
  @objectStoreNames = (name for name in objectStoreNames)
  if name in db
    console.warn("#{name} will mask a property of #{db} - your app may not function as expected")
  @[name] = new Store(db, name) for name in @objectStoreNames
  @
    
IndexTheBee = ({ name, version, migrations }) ->
  migrations ?= []
  version ?= 1
  new Promise (resolve, reject) ->
    request = indexedDB.open(name, version)
    request.addEventListener 'upgradeneeded', (event) ->
      { oldVersion, newVersion, target } = event
      migration(target.result) for migration in migrations[oldVersion...newVersion]
    request.addEventListener 'success', (event) ->
      db = new Database(event.target.result)
      IndexTheBee.databases.push(db)
      resolve db
    request.addEventListener 'error', (event) ->
      console.error("Failed to create database #{name}")
      reject(event.error)

IndexTheBee.databases = []

IndexTheBee.delete = (db) ->
  db = @databases.find((d) -> d.name is db) if typeof db is 'string'
  req = indexedDB.deleteDatabase(db.name)
  req.addEventListener 'success', (e) =>
    @databases = @databases.filter (x) -> x isnt db # :-/ not super optimised
  req.addEventListener 'error', (e) =>
    console.error("Failed to delete database: #{db}")

@indexTheBee = IndexTheBee
