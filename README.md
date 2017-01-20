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

tarbackup script management

## Module Description

This module manages include/excludes for a file backup script using tar

## Setup

### What tarbackup affects

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Setup Requirements **OPTIONAL**

This module requires pluginsync enabled

### Beginning with tarbackup

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

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

This is where you list OS compatibility, version compatibility, etc.

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
