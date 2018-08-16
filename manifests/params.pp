# @summary Sets the values of parameters based on certain conditions.
#
class mysql::params{
    case $::operatingsystemrelease{
        '16.04',
        '18.04':{
            $config_path = '/etc/mysql/mysql.conf.d/mysqld.cnf'
        }
        default:{
            $config_path = '/etc/mysql/my.cnf'
        }
    }
}
