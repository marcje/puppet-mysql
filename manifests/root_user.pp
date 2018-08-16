# @summary Manages the MySQL root user.
#
# @note
# Because the MySQL root user is an exceptional user we do not manage this user through the
# generic 'mysql::user' class alone.
#
# The exceptions we have made for this user are found underneath:
# * MySQL connection_string:
#   The MySQL connection_string uses the password retrieved by facter instead of the
#   password in the 'root_password' paramater. This is necessary to ensure we can 
#   connect with the database as root when we want to change the password through the parameter.
#
# * Another 'reload_privileges' exec:
#   When we update the root password we need to reload (flush) the privileges. Before doing this
#   the old password (as retrieved by facter) as used. Therefore a new reload_privileges using
#   this password is created for managing the root privileges alone.
#
# * Required hosts:
#   A set of required hosts (localhost and it's IPv4 / IPv6 addresses) are always
#   ensured for this user. This allows us to always be able to connect to MySQL from localhost.
#
# * Additional hosts:
#   We can expand the hosts the root user is allowed to connect from through a parameter.
#
# * Password type:
#   To ensure that we know what password is used the password type is set to 'plain_text'.
#
# * Hidden password file:
#   To be able to retrieve the current root password we created a small custom fact in ruby,
#   which reads the password from a hidden file. In this class said file is created and it content
#   updated with the password.
#
# * Permissions:
#   We ensure 'full' permissions on every root user, so it will be able to manage everything through root.
#
# * Unknown hosts:
#   Hosts that are not listed in the required_hosts list and additional_hosts list are deleted.
#
class mysql::root_user{
    $__mysql_connect = "mysql -uroot -p${facts['mysql_current_root_password']} -e"
    $required_root_hosts = ['localhost', '127.0.0.1', '::1']

    if($::mysql::additional_root_hosts){
        $__root_hosts = concat($::mysql::additional_root_hosts, $required_root_hosts)
    }
    else{
        $__root_hosts = $required_root_hosts
    }

    exec{'set_root_password_plugin':
        command => "${__mysql_connect} \"UPDATE mysql.user \
                                         SET plugin='mysql_native_password' \
                                         WHERE User='root';\"",
        onlyif  => "${__mysql_connect} \"SELECT User, Host \
                                         FROM mysql.user \
                                         WHERE User='root' \
                                           AND plugin='auth_socket';\" \
                                         | grep 'Host'",
        notify  => Exec['reload_mysql_privileges'],
        path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
    }

    unless($::mysql::root_password ==  $facts['mysql_current_root_password']){
        exec{'set_root_passwords':
            command => "${__mysql_connect} \"UPDATE mysql.user \
                                             SET Authentication_string=PASSWORD('${::mysql::root_password}') \
                                             WHERE User='root';\"",
            notify  => Exec['reload_mysql_root_privileges'],
            path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
        }
        ->exec{'reload_mysql_root_privileges':
            command     => "${__mysql_connect} \"FLUSH PRIVILEGES;\"",
            refreshonly => true,
            path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
        }
        ->file{'/root/.mysql_password':
            ensure  => present,
            owner   => 'root',
            group   => 'root',
            mode    => '0600',
            content => "${::mysql::root_password}\n"
        }
    }

    $__root_hosts.each | String $host |{
        mysql::user::ensure{"ensure_user_'root'@'${host}'":
            user          => 'root',
            host          => $host,
            state         => 'present',
            password      => $::mysql::root_password,
            password_type => 'plain_text'
        }
        mysql::user::permissions{"ensure_permissions_'root'@'${host}'":
            user      => 'root',
            host      => $host,
            state     => 'present',
            user_role => 'full',
            database  => '*'
        }
    }
    exec{'disallow_remote_root':
        command => "${__mysql_connect} \"DELETE FROM mysql.user \
                                         WHERE User='root' \
                                           AND Host NOT IN('${__root_hosts.join("', '")}');\"",
        onlyif  => "${__mysql_connect} \"SELECT User, Host \
                                         FROM mysql.user \
                                         WHERE User='root' \
                                           AND Host NOT IN ('${__root_hosts.join("', '")}');\" \
                                         | grep 'Host'",
        notify  => Exec['reload_mysql_privileges'],
        path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
    }
}
