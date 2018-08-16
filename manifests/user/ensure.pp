# @summary Ensures the state of MySQL users.
#
# @param user
#   The name of the user.
# @param host
#   The host the user will be able to connect from.
# @param state
#   The state we need to ensure for the user.
# @param password
#   The password to use for the user.
# @param password_type
#   Whether the password is a plain text string or an already hashed password.
#
# @note
# This define ensures the state of MySQL users by either creating or deleting an user if necessary.
#
# A password can be a string containing either a plain text password or a MySQL password hash. If
# the type is set on 'plain_text' MySQL will create a hash for us. If the type is set on 'hash' MySQL
# expects a hashed password.
#
define mysql::user::ensure(
    NotUndef[String]                     $user,
    NotUndef[String]                     $host,
    NotUndef[Enum['present', 'absent']]  $state,
    Optional[String]                     $password      = undef,
    Optional[Enum['hash', 'plain_text']] $password_type = undef
){
    $__mysql_connect = $::mysql::globals::mysql_connect
    $__full_user = "'${user}'@'${host}'"

    if($state == 'present'){
        if($password_type == 'plain_text'){
            $__password = "'${password}'"
        }
        else{
            $__password = "PASSWORD '${password}'"
        }
        exec{"create_user_${__full_user}":
            command => "${__mysql_connect} \"CREATE USER IF NOT EXISTS ${__full_user} IDENTIFIED BY ${__password};\"",
            unless  => "${__mysql_connect} \"SELECT User, Host \
                                             FROM mysql.user \
                                             WHERE User='${user}' \
                                               AND Host='${host}';\" \
                                             | grep 'Host'",
            notify  => Exec['reload_mysql_privileges'],
            path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
        }
    }
    if($state == 'absent'){
        exec{"remove_user_${__full_user}":
            command => "${__mysql_connect} \"DROP USER IF EXISTS ${__full_user};\"",
            onlyif  => "${__mysql_connect} \"SELECT User, Host \
                                             FROM mysql.user \
                                             WHERE User='${user}' \
                                               AND Host='${host}';\" \
                                             | grep 'Host'",
            notify  => Exec['reload_mysql_privileges'],
            path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
        }
    }
}
