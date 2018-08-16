# @summary Ensures the state of MySQL databases.
#
# @param database
#   The name of the database.
# @param state
#   The state we want the database to be in.
#
define mysql::database::ensure( String                    $database,
                                Enum['present', 'absent'] $state
){
    $__mysql_connect = $::mysql::globals::mysql_connect

    if($state == 'present'){
        exec{"create_database_${database}":
            command => "${__mysql_connect} \"CREATE DATABASE IF NOT EXISTS ${database};\"",
            unless  => "${__mysql_connect} \"SHOW DATABASES;\" | grep ${database}",
            path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin'],
        }
    }
    if($state == 'absent'){
        exec{"delete_database_${database}":
            command => "${__mysql_connect} \"DROP DATABASE ${database};\"",
            onlyif  => "${__mysql_connect} \"SHOW DATABASES;\" | grep ${database}",
            path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin'],
        }
    }
}
