# @summary Handles the main configuration of a MySQL server.
#
class mysql::config{
    file{$::mysql::config_path:
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => epp('mysql/mysqld.cnf.epp'),
    }
}
