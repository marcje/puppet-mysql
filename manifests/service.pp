# @summary Handles the MySQL service.
#
class mysql::service{
    service { 'mysql':
        ensure => 'running',
        name   => 'mysql',
    }
}
