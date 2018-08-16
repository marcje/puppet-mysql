# @summary Defines global variables and resources to use throughout the rest of the module.
#
class mysql::globals{
    # Global variables
    $mysql_connect = "mysql -uroot -p${::mysql::root_password} -e"

    # Global resources
    exec{'reload_mysql_privileges':
        command     => "${mysql_connect} \"FLUSH PRIVILEGES;\"",
        refreshonly => true,
        path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
    }
}
