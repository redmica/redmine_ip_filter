# Redmine IP Filter

Redmine plugin for access filtering using IP address.

## Features

* Filtering access to redmine site. 
* Setting the filtering rules on Redmine Admin-Page.

## Filtering access to redmine site. 

add the Filtering module on Redmine, and filtering the access to Redmine site using the Access remote IP address.
If the Access remote IP address corresponds to the network address or host address registered in the filtering rules, allow access to the Redmine site.
If the filtering rules is not registered, to allow all access.

## Setting the filtering rules on Redmine Admin-Page.

setting of filtering rules, operate from the Redmine administrator page.

![Setting Page](images/setting_page.png?raw=true "Setting Page on Redmine Admine Page")

Host address or Network address can be specified in Filtering rules.
Access source IP address, which is operating the Redmine management screen, must have been included in the filtering rules.

## Install

## Install Redmine plugin

#### Place the plugin source at Redmine plugins directory.

`git clone` or copy an unarchived plugin to
`plugins/redmine_ip_filter` on your Redmine installation path.

```
$ git clone https://www.github.com/redmica/redmine_ip_filter.git /path/to/redmine/plugins/redmine_ip_filter
```

## Test

```
$ cd /path/to/redmine
$ bundle exec rake redmine:plugins:test NAME=redmine_ip_filter RAILS_ENV=test
```


## Uninstall

#### Remove the plugin directory.

```
$ cd /path/to/redmine
$ rm -rf plugins/redmine_ip_filter
```

## Licence

This plugin is licensed under the GNU General Public License, version 2 (GPLv2)

## Author

[Takenori Takaki (Far End Technologies)](https://www.farend.co.jp)
