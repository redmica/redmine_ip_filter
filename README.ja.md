# Redmine IP Filter

IPアドレスを用いたアクセス制限を実現するRedmineプラグイン.

## 機能

* Redmineサイトへのアクセス制限
* Redmine管理画面からのフィルタリングルール設定

## Redmineサイトへのアクセス制限

Redmineにフィルタリングモジュールを追加し、アクセス元のIPアドレスを使用してRedmineのサイトへのアクセスをフィルタリングします。
アクセス元のIPアドレスがフィルタリングルールに登録されたネットワークアドレスまたはホストアドレスに対応する場合、Redmineのサイトへのアクセスを許可します。
フィルタリングルールが登録されていない場合は、すべてのアクセスを許可します。

## Redmine管理画面からのフィルタリングルール設定

フィルタリングルールの設定は、Redmineの管理者ページから操作します。

![Setting Page](images/setting_page.ja.png?raw=true "Setting Page on Redmine Admine Page")

ホストアドレスやネットワークアドレスをフィルタリングルールに指定することができます。
Redmineの管理画面を操作しているアクセス元IPアドレスは、フィルタリングルールに含まれている必要があります。

## インストール

## Redmineプラグインのインストール

#### Redmineのプラグインディレクトリにredmine_ip_filterのソースを配置します。

Redmineがインストールされたパスの `plugins/redmine_ip_filter` ディレクトリ
`git clone` するか展開済みのソースを配置します。

```
$ git clone https://www.github.com/redmica/redmine_ip_filter.git /path/to/redmine/plugins/redmine_ip_filter
```

## テスト

```
$ cd /path/to/redmine
$ bundle exec rake redmine:plugins:test NAME=redmine_ip_filter RAILS_ENV=test
```


## アンインストール

#### プラグインのディレクトリを削除します。

```
$ rm -rf plugins/redmine_ip_filter
```

## ライセンス

This plugin is licensed under the GNU General Public License, version 2 (GPLv2)

Icons credits:

* Paweł Kuna (Tabler Icons https://tabler.io/icons) licensed under [MIT License](https://opensource.org/license/mit).
