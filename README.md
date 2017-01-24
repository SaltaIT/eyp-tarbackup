# tarbackup

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What tarbackup affects](#what-tarbackup-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with tarbackup](#beginning-with-tarbackup)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)
    * [TODO](#todo)
    * [Contributing](#contributing)

## Overview

file backup script management

## Module Description

This module manages include/excludes for a file backup script using tar

## Setup

### What tarbackup affects

* backup script installation (managed using **tarbackup**)
* backup configuration files (managed using **tarbackup::instance**)
* backup cronjobs (managed using **tarbackup::instance**)

### Setup Requirements **OPTIONAL**

This module requires pluginsync enabled

### Beginning with tarbackup

basic example:

```puppet
class { 'tarbackup':
}

tarbackup::instance { 'coses':
  includedir => '/etc',
  includedir => '/etc/apache2',
  xdev => true,
  destination => '/backup/tarbackup',
}
```

This will create the following files:

* **/usr/local/bin/tarbackup.sh**
* **/usr/local/bin/tarbackup_coses.config**

And add the following cronjob:

```
# Puppet Name: cronjob tarball backup tarbackup
0 2 * * * /usr/local/bin/tarbackup.sh /usr/local/bin/tarbackup_coses.config
```

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

### classes

#### tarbackup

installs backup script

* **basedir**: where to install this script (default: /usr/local/bin)
* **backupscript**: script name (default: tarbackup)

### define

#### tarbackup::instance

adds a cronjob por a given set of files to backup

* **destination**:
* **includedir**:
* **instancename**: = $name,
* **backupname**:   (default: Files)
* **excludedir**:   = undef,
* **retention**:    = undef,
* **logdir**:       = undef,
* **mailto**:       = undef,
* **idhost**:       = undef,
* **hour**:         (default: 2)
* **minute**:       (default: 0)
* **month**:        = undef,
* **monthday**:     = undef,
* **weekday**:      = undef,
* **setcron**:      (default: true)
* **xdev**:         (default: false)

## Limitations

Tested on:
* CentOS 6
* CentOS 7
* Ubuntu 16.04

but should work anywhere where there is a **/bin/bash** installed

## Development

We are pushing to have acceptance testing in place, so any new feature should
have some test to check both presence and absence of any feature

### TODO


### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
