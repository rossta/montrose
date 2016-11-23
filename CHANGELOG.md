### 0.5.0 - (2016-11-23)

* enhancements
  * Adds `Recurrence#include?`
  * Improved documentation

### 0.4.3 - (2016-11-20)

* enhancements
  * Add CI support for ActiveSupport 4.1, 4.2, 5.0 (by @phlipper)

### 0.4.2 - (2016-07-27)

* bug fixes
  * Respect `ActiveSupport::TimeWithZone` objects for casting time objects (by
    @tconst)

### 0.4.1 - (2016-07-04)

* enhancements
  * Support `Montrose.every(:second)`

* bug fixes
  * Ensure `ActiveSupport::Duration` parts are used; fixes 'every 30 days' bug

### 0.4.0 - (2016-04-20)

* enhancements
  * Respect configured time zone by using `Time.current` from `ActiveSupport`
  * Adds `Montrose::Recurrence#to_json` method
  * Additional tests for utils methods (by @AlexWheeler)

### 0.3.0 - (2016-02-19)

* enhancements
  * Adds `:except` option and chainable method to filter timestamps by date (by
    @thewatts)
* bug fixes
  * Fix recurrences when specifying both `:starts` and `:at` by treating
    `:starts` value like a date
  * Respect recurrence rules using multiple `:at` values
  * Using `Montrose.r` without any arguments no longer throws `ArgumentError`

### 0.2.2 - 2016-02-08

* bug fixes
  * Handle `Hash` in `Montrose::Chainable` methods that support varargs
* enhancements
  * Adds `Montrose.r` method for starting a new recurrence
  * Adds `Chainable` alias methods including `#starts`, `#until`, `#repeat`
  * README updates (by @thegcat)

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
