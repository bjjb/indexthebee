{ expect } = require 'chai'

indexedDB = require 'fake-indexeddb'
Promise = require 'bluebird'

Database = require '../indexTheBee'
Database.set({ Promise, indexedDB })

describe "a Database", ->
  migrations = [
    ->
      @createObjectStore('orders', keyPath: 'id', autoIncrement: true)
    ->
      @objectStore('orders').createIndex 'date', unique: false
  ]
  it "is a function", ->
    expect(Database).to.be.a 'function'
  it "is created properly", ->
    db = new Database('test', 1, migrations)
    expect(db).to.be.an.instanceOf Database
  it "can count data", (done) ->
    db = new Database('test', 1, migrations)
    db.orders.count().then (count) ->
      expect(count).to.be 3
      done()
  it "can count data by an index"
  it "can count data by an index with constraints"
  it "can get data"
  it "can get data by an index"
  it "can get data by an index with constraints"
  it "can getAll data"
  it "can getAll data by an index"
  it "can put data by an index with constraints"
  it "can getAll data"
  it "can getAll data by an index"
  it "can getAll data by an index with constraints"
