# Index the Bee

A small, promising [IndexedDB][] wrapper.

## Installation

With NPM...

    npm install --save indexthebee

... or Bower

    bower install indexthebee

... or from source

    git clone git://github.com/bjjb/indexthebee.git
    cd indexthebee
    npm install
    ./node_modules/bin/cake build

## Setup

In a browser, add

```
<script src="/path/to/indexthebee.js"></script>

<script>
  var dbname = "My database"
  var dbversion = 2
  var db = IndexTheBee('dbname', dbversion, migrations)
</script>
```

Migrations are optional, but if the DB at `dbname` isn't the right version,
you'll want to run some. Migrations should be an array of functions that are
called with the version-change transaction as an argument.

For server-side environments, IndexedDB is not available by default, so you'll
need to install an implementation. It also needs a Promises/A+ implementation.

```
var indexedDB = require 'some-idb-lib'
var Promise = require 'some-promise-lib'
var IndexTheBee = require 'indexthebee'
var Database = IndexTheBee({ indexedDB: indexedDB, Promise: Promise })
var db = Database(dbname, dbversion, migrations)
```

## Usage

```
db.createStore('dogs', keyPath: 'id', autoIncrement: true)    // Promises!
  .then(function() { return db.dogs.add({ name: 'Rover' }))   // Stores as properties on the db!
  .then(function() { return db.dogs.add({ name: 'Fido' }))     
  .then(function() { return db.dogs.addIndex('name', 'name')) // Easy index creation!
  .then(function() { return db.dogs.name.get('Fido'))         // Indexes as properties on the store!
  .then(function() { return db.dogs.count())                  // Familiar API
  .then(function() { return db.dogs.getAll())                 // ...with some additions.
```

Check out the tests on the [project page](http://bjjb.github.io/indexthebee).

IndexTheBee was written by bjjb, and is
[open source](http://github.io/bjjb/indexthebee/blob/master/LICENSE.txt).

[indexedDB]: http://www.w3.org/TR/IndexedDB/
