# @summary Processes additional steps to create a more secure MySQL environment.
#
# @note
# This class processes some additional steps to create a more secure MySQL environment.
#
# By default MySQL installs a 'test' database, which we will remove. Privileges assigned to this database
# will also be removed. If a database with the name 'test' or privileges for this databases are created
# again Puppet will delete it through this class.
#
# Users with an empty username (anonymous users) or without a password will be removed as well, since we
# decided to not allow those on our servers when 'secure_install' is set to true.
#
# Lastly, the .mysql_history file for the root user will be pointed to /dev/null to ensure sensitive data
# is not stored.
#
class mysql::secure_install{
    $__mysql_connect = $::mysql::globals::mysql_connect

    exec{'remove_test_database':
        command => "${__mysql_connect} \"DROP DATABASE test;\"",
        onlyif  => "${__mysql_connect} \"SELECT SCHEMA_NAME \
                                         FROM information_schema.SCHEMATA \
                                         WHERE SCHEMA_NAME='test';\" \
                                         | grep test",
        notify  => Exec['remove_test_database_privileges'],
        path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
    }
    ->exec{'remove_test_database_privileges':
        command     => "${__mysql_connect} \"DELETE FROM mysql.db \
                                             WHERE Db='test' \
                                                OR Db='test\\_%';\"",
        onlyif      => "${__mysql_connect} \"SELECT Db \
                                             FROM mysql.db \
                                             WHERE Db='test' \
                                                OR Db='test\\_%';\"",
        notify      => Exec['reload_mysql_privileges'],
        refreshonly => true,
        path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
    }
    ->exec{'remove_passwordless_users':
        command => "${__mysql_connect} \"DELETE FROM mysql.user \
                                         WHERE authentication_string='';\"",
        onlyif  => "${__mysql_connect} \"SELECT User, Host \
                                         FROM mysql.user \
                                         WHERE authentication_string='';\" \
                                         | grep 'Host'",
        notify  => Exec['reload_mysql_privileges'],
        path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
    }
    ->exec{'remove_anonymous_users':
        command => "${__mysql_connect} \"DELETE FROM mysql.user \
                                         WHERE User='';\"",
        onlyif  => "${__mysql_connect} \"SELECT User, Host \
                                         FROM mysql.user \
                                         WHERE User='';\" \
                                         | grep 'Host'",
        notify  => Exec['reload_mysql_privileges'],
        path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
    }
    ->file{'/root/.mysql_history':
        ensure => link,
        target => '/dev/null'
    }
}
