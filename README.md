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

#### Preventing IP address spoofing

An attacker may be able to bypass access control done by this plugin if the Redmine server directly accepts HTTP requests from clients without a reverse proxy server or a load balancer (see https://api.rubyonrails.org/classes/ActionDispatch/RemoteIp.html for details).

To prevent such an attack, you have to drop `X-Forwarded-For` field from an HTTP request header if you don't use a reverse proxy server that adds `X-Forwarded-For` field.

It can be done by configuring the web server. For example, if you are using Apache, use the `RequestHeader` directive:

```
RequestHeader unset X-Forwarded-For
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

## Command line tools

### Add IP addresses to the allowed IP addresses

```
$ cd /path/to/redmine
$ bin/rails redmine_ip_filter:filters:add ADDR=198.51.100.10
ADD     198.51.100.10
$ bin/rails redmine_ip_filter:filters:add ADDR=198.51.100.11,192.0.2.0/28
ADD     198.51.100.11
ADD     192.0.2.0/28
```

### Delete IP addresses from the allowed IP addresses

```
$ cd /path/to/redmine
$ bin/rails redmine_ip_filter:filters:delete ADDR=198.51.100.11
DELETE  198.51.100.11
```

### Show the allowed IP addresses

```
$ bin/rails redmine_ip_filter:filters:show
198.51.100.10
192.0.2.0/28
```

### Test if given IP addresses are allowed

```
$ bin/rails redmine_ip_filter:filters:test REMOTE_ADDR=192.0.2.15,192.0.2.16
ALLOW   192.0.2.15
REJECT  192.0.2.16
```


## Licence

This plugin is licensed under the GNU General Public License, version 2 (GPLv2)

Icons credits:

* Paweł Kuna (Tabler Icons https://tabler.io/icons) licensed under [MIT License](https://opensource.org/license/mit).

## Author

[Takenori Takaki (Far End Technologies)](https://www.farend.co.jp)
