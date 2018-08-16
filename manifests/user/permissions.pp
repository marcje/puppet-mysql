# @summary Manages permissions on databases for MySQL users.
#
# @param user
#   The name of the user.
# @param host
#   The host the user will be able to connect from.
# @param state
#   The state we want the user to be in.
# @param database
#   The database to give a user permissions on. Use '*' for global permissions.
# @param user_role
#   The role of the user. See the notes for an overview on the available roles and their use.
#
# @note
# This define manages permissions on databases for MySQL users by predefined roles.
#
# A MySQL user has global permissions in the mysql.user table and database specific permissions
# in the mysql.db table. Based on the 'database' parameter being either a database name or an
# asterisk (*), the permissions for the user will be set globally or for a specific database.
#
# By using our own Ruby functions a permission list (which is a hash) is generated, which is
# used to generate the different necessary queries, like an insert query and a select query
# which both will contain the right columns and values in the proper query format.
#
# These queries will be used in the required exec's for managing the permissions.
#
# When the state of an user is 'absent' the permissions will only be deleted when they are database
# specific permissions. Global permissions are already deleted by ensuring the user to be absent.
#
# The different roles grant predefined permissions on a user. An overview can be found in the README.md file.
#
define mysql::user::permissions(
    NotUndef[String]                        $user,
    NotUndef[String]                        $host,
    NotUndef[Enum['present', 'absent']]     $state,
    NotUndef[String]                        $database,
    NotUndef[Enum['read_only',
                  'read_write',
                  'read_write_extended',
                  'slave',
                  'none',
                  'full']]                  $user_role
){
  $__mysql_connect = $::mysql::globals::mysql_connect

  if($state == 'present'){
    if($database == '*'){
        $__full_user = "'${user}'@'${host}'"
        $permission_list = mysql::get_permission_list('global', $user_role)
        $select_query = mysql::generate_query('select', $user, $host, $permission_list, true)
        $update_query = mysql::generate_query('update', $user, $host, $permission_list)
    }
    else{
        $__full_user = "'${user}'@'${host}'@'${database}'"
        $permission_list = mysql::get_permission_list('database_specific', $user_role)
        $basic_select_query = mysql::generate_query('select', $user, $host, $permission_list, false, $database)
        $select_query = mysql::generate_query('select', $user, $host, $permission_list, true, $database)
        $insert_query = mysql::generate_query('insert', $user, $host, $permission_list, false, $database)
        $update_query = mysql::generate_query('update', $user, $host, $permission_list, false, $database)

        exec{"insert_privileges_${__full_user}":
            command => "${__mysql_connect} \"${insert_query}\"",
            unless  => "${__mysql_connect} \"${basic_select_query};\" | grep 'Host'",
            notify  => Exec['reload_mysql_privileges'],
            path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
        }
    }
    exec{"update_privileges_${__full_user}":
        command => "${__mysql_connect} \"${update_query}\"",
        unless  => "${__mysql_connect} \"${select_query};\" | grep 'Host'",
        notify  => Exec['reload_mysql_privileges'],
        path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
    }
  }
  if($state == 'absent') and ($database != '*'){
    $__full_user = "'${user}'@'${host}'@'${database}'"

    exec{"delete_privileges_${__full_user}":
        command => "${__mysql_connect} \"DELETE FROM mysql.db \
                                         WHERE User='${user}' \
                                           AND Host='${host}' \
                                           AND Db='${database}';\"",
        onlyif  => "${__mysql_connect} \"SELECT User, Host \
                                         FROM mysql.db \
                                         WHERE User='${user}' \
                                           AND Host='${host}' \
                                           AND Db='${database}';\" \
                                         | grep 'Host'",
        notify  => Exec['reload_mysql_privileges'],
        path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin']
    }
  }
}
