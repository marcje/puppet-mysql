# @summary Initializes the MySQL module.
#
# @param root_password
#   Password for the root user in plain text.
# @param secure_install
#   Whether to secure the installation or leave it as default.
# @param config_path
#   The path to the configuration file. Defaults to a location determined by the params class.
# @param port
#   The port MySQL should listen on.
# @param bind_address
#   Binds MySQL to a specific IP address.
# @param skip_networking
#   Whether to allow network connections or local connections only.
# @param default_storage_engine
#   Sets the default storage engine the server uses.
# @param max_connections
#   Sets the maximum amount of permitted connections.
# @param max_connect_errors
#   Sets the amount of permitted connection errors before a host will be blocked.
# @param max_allowed_packet
#   Sets the maximum permitted packet size of packets handled by MySQL.
# @param thread_stack
#   Sets the stack size of each thread.
# @param thread_cache_size
#   Sets the amount of (unused) threads to store in a cache.
# @param table_cache
#   Sets the amount of open tables for all threads.
# @param explicit_timestamp_defaults
#   When disabled MySQL will handle default values for timestamp records in a nonstandard way.
# @param local_infile
#   Enables the ability to load a local file into MySQL. Use with caution due to security risks.
# @param key_buffer_size
#   Sets the size of the buffer used for index blocks.
# @param myisam_recover_options
#   Sets the MyISAM storage engine recovery mode.
# @param innodb_buffer_pool_size
#   Sets the size of the InnoDB buffer pool for caching data and indexes.
# @param innodb_buffer_pool_instances
#   Sets the number of regions the InnoDB buffer pool is divided into.
# @param innodb_log_file_size
#   Sets the size of InnoDB log files.
# @param innodb_log_buffer_size
#   Sets the size of the InnoDB buffer, allowing transactions to run without writing to disk before the transaction is committed.
# @param innodb_file_per_table
#   Splits InnoDB database files per table instead of one big file.
# @param innodb_stats_on_metadata
#   Will update InnoDB index statistics when enabled.
# @param innodb_large_prefix
#   Allows larger prefixes for index columns.
# @param query_cache_limit
#   Sets the maximum limit for the size of queries to cache.
# @param query_cache_size
#   When enabled will keep queries in cache. Use with caution for this option is known to cause performance issues.
# @param enable_general_log
#   Enables general query logging.
# @param enable_error_log
#   Enables the logging of MySQL errors.
# @param enable_slow_log
#   Enables the logging of slow queries.
# @param long_query_time
#   Sets the amount of seconds before a query is considered slow.
# @param server_type
#   Specifies the type of the server, necessary in a master / slave setup.
# @param enable_ssl
#   Enables encrypted / SSL connections to the MySQL server.
# @param additional_root_hosts
#   Sets additional hosts for the root user to connect from.
# @param server_id
#   Sets the (unique) server id for a master / slave setup.
# @param log_expiration
#   Sets the amount of days after which binary logs should expire.
# @param binlog_size
#   Sets the size of logfiles after which they should be rotated.
# @param log_bin
#   Sets the path to the binary log.
# @param replicate_db
#   Specifies which databases should be replicated in a master / slave setup.
# @param ssl_ca_cert
#   Specifies the location to the SSL Certificate Authority file.
# @param ssl_cert
#   Specifies the location to the SSL Certificate file.
# @param ssl_key
#   Specifies the location to the SSL private key file.  
# @param databases
#   Contains databases to manage through Puppet. See the README for a full example for this parameter.
# @param users
#   Contains users to manage through Puppet. See the README for a full example for this parameter.
#
# @note
# Within this class we defined some parameters that need an integer value followed by a string value
# in order to define a certain value (in example the query_cache_size parameter, which defaults to '16M'.
# This has been done to prevent parameters from getting too complex, leaving the user to specify which
# value they want to set.
#
# For the same reason (preventing parameters from getting too complex) we did specify some ENUM's, but
# have left more complex parameter objects to the validation class. Their format is found in the README.
#
# A lot of the parameters have pretty standard defaults. This has been done so the module is rather easy
# and standard to use out of the box, but allows people to easily override settings.
#
class mysql(
    NotUndef[String]            $root_password,
    NotUndef[Boolean]           $secure_install                 =   true,
    NotUndef[String]            $config_path                    =   $mysql::params::config_path,
    NotUndef[Integer]           $port                           =   3306,
    NotUndef[String]            $bind_address                   =   '127.0.0.1',
    NotUndef[Boolean]           $skip_networking                =   false,
    NotUndef[Enum['innodb',
                  'myisam',
                  'memory',
                  'csv',
                  'archive',
                  'blackhole',
                  'ndb',
                  'merge',
                  'federated',
                  'example']]   $default_storage_engine         =   'innodb',
    NotUndef[Integer]           $max_connections                =   150,
    NotUndef[Integer]           $max_connect_errors             =   100,
    NotUndef[String]            $max_allowed_packet             =   '16M',
    NotUndef[String]            $thread_stack                   =   '256K',
    NotUndef[Integer]           $thread_cache_size              =   8,
    NotUndef[Integer]           $table_cache                    =   64,
    NotUndef[Boolean]           $explicit_timestamp_defaults    =   true,
    NotUndef[Boolean]           $local_infile                   =   false,
    NotUndef[String]            $key_buffer_size                =   '16M',
    NotUndef[Enum['off',
                  'backup',
                  'backup_all',
                  'default',
                  'force',
                  'quick']]     $myisam_recover_options         =   'backup',
    NotUndef[String]            $innodb_buffer_pool_size        =   '1G',
    NotUndef[Integer]           $innodb_buffer_pool_instances   =   8,
    NotUndef[String]            $innodb_log_file_size           =   '1G',
    NotUndef[String]            $innodb_log_buffer_size         =   '16M',
    NotUndef[Boolean]           $innodb_file_per_table          =   true,
    NotUndef[Boolean]           $innodb_stats_on_metadata       =   false,
    NotUndef[Boolean]           $innodb_large_prefix            =   true,
    NotUndef[String]            $query_cache_limit              =   '1M',
    NotUndef[String]            $query_cache_size               =   '0',
    NotUndef[Boolean]           $enable_general_log             =   false,
    NotUndef[Boolean]           $enable_error_log               =   false,
    NotUndef[Boolean]           $enable_slow_log                =   false,
    NotUndef[Integer]           $long_query_time                =   2,
    NotUndef[Enum['standalone',
                  'master',
                  'slave']]     $server_type                    =   'standalone',
    NotUndef[Boolean]           $enable_ssl                     =   false,
    Optional[Array]             $additional_root_hosts          =   undef,
    Optional[Integer]           $server_id                      =   undef,
    Optional[Integer]           $log_expiration                 =   undef,
    Optional[String]            $binlog_size                    =   undef,
    Optional[String]            $log_bin                        =   undef,
    Optional[Array]             $replicate_db                   =   undef,
    Optional[String]            $ssl_ca_cert                    =   undef,
    Optional[String]            $ssl_cert                       =   undef,
    Optional[String]            $ssl_key                        =   undef,
    Optional[Hash]              $databases                      =   undef,
    Optional[Array]             $users                          =   undef,
)inherits mysql::params{
    require mysql::validation
    include mysql::globals
    contain mysql::service

    class{'mysql::install':
        notify => Class['mysql::service']
    }

    class{'mysql::config':
        notify => Class['mysql::service']
    }

    class{'mysql::root_user':}

    if($secure_install == true){
        class{'mysql::secure_install':
            require => Anchor['mysql::finished_installation']
        }
    }

    if($databases){
        class{'mysql::database':
            require => Anchor['mysql::finished_config']
        }
    }
    if($users){
        class{'mysql::user':
            require => Anchor['mysql::finished_database']
        }
    }

    Class['mysql::install']
    ->Class['mysql::config']
    ->Class['mysql::root_user']
    ->Anchor{'mysql::finished_installation':}
    ->Anchor{'mysql::finished_config':}
    ->Anchor{'mysql::finished_database':}
}
