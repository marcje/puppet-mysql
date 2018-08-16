# @summary Manages passwords for MySQL users.
#
# @param user
#   The name of the user.
# @param host
#   The host the user will be able to connect from.
# @param password
#   The password to use for the user.
# @param password_type
#   The type of the password that is used.
#
# @note
# This define manages passwords for MySQL users.
#
# A password can be a string containing either a plain text password or a MySQL password hash. If
# the type is set on 'plain_text' we use MySQL's PASSWORD() function to create a hash ourselves.
#
define mysql::user::password(
    NotUndef[String]                     $user,
    NotUndef[String]                     $host,
    NotUndef[String]                     $password,
    NotUndef[Enum['plain_text', 'hash']] $password_type
){
    $__mysql_connect = $::mysql::globals::mysql_connect

    if($password_type == 'plain_text'){
        $__password = "PASSWORD('${password}')"
    }
    else{
        $__password = "'${password}'"
    }

    exec{"set_password_'${user}'@'${host}'":
            command => "${__mysql_connect} \"UPDATE mysql.user \
                                             SET Authentication_string=${__password} \
                                             WHERE User='${user}' \
                                               AND Host='${host}';\"",
            unless  => "${__mysql_connect} \"SELECT User, Host \
                                             FROM mysql.user \
                                             WHERE User='${user}' \
                                               AND Host='${host}' \
                                               AND Authentication_string=${__password};\" \
                                             | grep 'Host'",
            notify  => Exec['reload_mysql_privileges'],
            path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
    }
}
