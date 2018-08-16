# @summary Manages MySQL databases.
#
class mysql::database{
    $::mysql::databases.each |String $database, String $ensure|{
        mysql::database::ensure{"ensure_${database}":
            database => $database,
            state    => $ensure
        }
    }
}
