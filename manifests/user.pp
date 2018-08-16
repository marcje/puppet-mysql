# @summary Manages MySQL users.
#
# @note
# This class manages MySQL users by retrieving their information from the user hash and
# pass this information along to the corresponding user related defined types.
#
# The global 'ensure' state of a user determines whether an user will be managed or not.
# If this state is set to 'absent' the complete user and all of their settings will be
# deleted, regardless what the other settings have been set to.
#
# Upon deleting an user every permission set in the 'user' parameter for said user will
# be deleted as well. Any 'unmanaged' settings, if there are any, will be skipped as Puppet
# will not know about these settings.
#
class mysql::user{
    $::mysql::users.each | Hash $user|{
        if($user['ensure'] == 'present'){
            $user['hosts'].each | Array $host|{
                mysql::user::ensure{"ensure_'${user['name']}'@'${host[0]}'":
                    user          => $user['name'],
                    host          => $host[0],
                    state         => $host[1],
                    password      => $user['password'],
                    password_type => $user['password_type']
                }
                if($host[1] == 'present'){
                    mysql::user::password{"ensure_password_'${user['name']}'@'${host[0]}'":
                        user          => $user['name'],
                        host          => $host[0],
                        password      => $user['password'],
                        password_type => $user['password_type']
                    }
                }
                $user['permissions'].each | Array $permission|{
                    mysql::user::permissions{"ensure_permissions_'${user['name']}'@'${host[0]}'@'${permission[0]}'":
                        user      => $user['name'],
                        host      => $host[0],
                        state     => $host[1],
                        user_role => $permission[1],
                        database  => $permission[0],
                    }
                }
            }
        }
        if($user['ensure'] == 'absent'){
            $user['hosts'].each | Array $host|{
                mysql::user::ensure{"ensure_'${user['name']}'@'${host[0]}'":
                    user  => $user['name'],
                    host  => $host[0],
                    state => 'absent'
                }
                $user['permissions'].each | Array $permission|{
                    mysql::user::permissions{"delete_permissions_'${user['name']}'@'${host[0]}'@'${permission[0]}'":
                        user      => $user['name'],
                        host      => $host[0],
                        state     => 'absent',
                        user_role => $permission[1],
                        database  => $permission[0],
                    }
                }
            }
        }
    }
}
