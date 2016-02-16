### 0.3.0 - (unreleased)

* enhancements
  * Adds `:except` option and chainable method to filter timestamps by date (by
    @thewatts)
* bug fixes
  * Using `Montrose.r` without any arguments no longer throws `ArgumentError`

### 0.2.2 - 2016-02-08

* bug fixes
  * Handle `Hash` in `Montrose::Chainable` methods that support varargs
* enhancements
  * Adds `Montrose.r` method for starting a new recurrence
  * Adds `Chainable` alias methods including `#starts`, `#until`, `#repeat`

### 0.2.1 - 2016-02-03

* bug fixes
  * Handle `nil` in `Montrose::Options` constructor

### 0.2.0 - 2016-02-03

* enhancements
  * extend `Montrose::Schedule` api for building and adding recurrences
  * add more details to chainable docs
  * merge default options at enumeration time for more consistent serialization

### 0.1.1 - 2016-25-01

* bug fixes
  * add missing `require "forwardable"`
* enhancements
  * add better `#inspect` methods in `Recurrence` and `Options`
  * use refinement to refactor Options internal arg merging
  * support ruby 2.3.0 in travis builds

### 0.1.0 - 2016-18-01

* initial release
