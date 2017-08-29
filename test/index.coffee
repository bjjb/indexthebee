'use strict'

describe 'IndexTheBee', ->
  beforeEach (done) ->
    done()

  afterEach (done) ->
    done()

  it 'is a function', ->
    expect(indexTheBee).to.be.a('function')

  it 'creates a promise', ->
    expect(indexTheBee(name: 'null database')).to.respondTo 'then'

  describe 'The fulfillment of the promise', ->
    db = null
    before (done) ->
      indexTheBee(name: 'null database').then (x) ->
        db = x
        done()
    after (done) ->
      done()
    it 'is a database', ->
      expect(db).to.be.a('object')
    it 'has (no) object stores', ->
      expect(db.objectStoreNames).to.have.length 0
    it 'has the right name', ->
      expect(db.name).to.eq 'null database'
      
  describe 'when called with a name', ->
    db = null
    before (done) ->
      indexTheBee(name: 'sammy smitherbase').then (x) ->
        db = x
        done()
    it 'has the right name', ->
      expect(db.name).to.eq 'sammy smitherbase'

  describe 'object store creation', ->
    v1 = (db) -> db.createObjectStore('A')
    v2 = (db) -> db.createObjectStore('B')
    v3 = (db) -> db.createObjectStore('C')
    config =
      name: 'simple test'
      version: 1
      migrations: [v1, v2, v3]
    it "creates the 'simple test' database", (done) ->
      indexTheBee(config).then (db) ->
        expect(db.name).to.eq 'simple test'
        expect(db.version).to.eq 1
        expect(db.objectStoreNames).to.deep.equal ['A']
      .then -> done()
      .catch done

  describe 'migration', ->
    v1 = (db) -> db.createObjectStore('A')
    v2 = (db) -> db.createObjectStore('B')
    v3 = (db) -> db.createObjectStore('C')
    config =
      name: 'simple test'
      version: 3
      migrations: [v1, v2, v3]
    it 'migrates up to the given version', (done) ->
      indexTheBee(config).then (db) ->
        expect(db.name).to.eq 'simple test'
        expect(db.version).to.eq 3
        expect(db.objectStoreNames).to.deep.equal ['A', 'B', 'C']
      .then -> done()
      .catch done
