# @summary Handles the installation of a MySQL server.
#
class mysql::install{
    package{'mysql-server':
        ensure => 'installed',
    }
}
