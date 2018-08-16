# @summary Creates a permission hash for MySQL users.
Puppet::Functions.create_function(:'mysql::get_permission_list') do
    # @param permission_type
    #   Whether to return global or database specific permissions.
    # @param user_role
    #   The role of the user to define which privileges they should get.
    # @return [Hash] Returns the permissions in a hash.
    # @raise PuppetError When an incorrect value is given for the user_role parameter.
    # @raise PuppetError When trying to assign global permissons when permisison_type is set to 'database_specific'.
    # @note
    # This function defines a default hash with every permission set to 'N'. Based on the given role for
    # a user the values will be overwritten and set to 'Y', which can be used for setting permissions in MySQL.
    dispatch :role_specific_permissions do
        required_param "Enum['global', 'database_specific']",    :permission_type
        required_param 'String',    :user_role
        return_type 'Hash'
    end

    public
    def default_permissions(permission_type)
        basic_permissions = {'Select_priv'           => 'N',
                             'Insert_priv'           => 'N',
                             'Update_priv'           => 'N',
                             'Delete_priv'           => 'N',
                             'Create_priv'           => 'N',
                             'Drop_priv'             => 'N',
                             'Grant_priv'            => 'N',
                             'References_priv'       => 'N',
                             'Index_priv'            => 'N',
                             'Alter_priv'            => 'N',
                             'Create_tmp_table_priv' => 'N',
                             'Lock_tables_priv'      => 'N',
                             'Create_view_priv'      => 'N',
                             'Show_view_priv'        => 'N',
                             'Create_routine_priv'   => 'N',
                             'Alter_routine_priv'    => 'N',
                             'Execute_priv'          => 'N',
                             'Event_priv'            => 'N',
                             'Trigger_priv'          => 'N'}
 
        if(permission_type == 'global')
            global_permissions = {'Reload_priv'             => 'N',
                                  'Shutdown_priv'           => 'N',
                                  'Process_priv'            => 'N',
                                  'File_priv'               => 'N',
                                  'Show_db_priv'            => 'N',
                                  'Super_priv'              => 'N',
                                  'Repl_slave_priv'         => 'N',
                                  'Repl_client_priv'        => 'N',
                                  'Create_user_priv'        => 'N',
                                  'Create_tablespace_priv'  => 'N'}
            return basic_permissions.merge(global_permissions)
        else
            return basic_permissions
        end
    end

    public
    def role_specific_permissions(permission_type, user_role)
        case user_role
            when 'read_only'
                override_permissions = {'Select_priv' => 'Y'}
            when 'read_write'
                override_permissions = {'Select_priv' => 'Y',
                                        'Insert_priv' => 'Y',
                                        'Update_priv' => 'Y',
                                        'Delete_priv' => 'Y',
                                        'Create_priv' => 'Y',
                                        'Drop_priv'   => 'Y',
                                        'Index_priv'  => 'Y',
                                        'Alter_priv'  => 'Y'}
            when 'read_write_extended'
                override_permissions = {'Select_priv'           => 'Y',
                                        'Insert_priv'           => 'Y',
                                        'Update_priv'           => 'Y',
                                        'Delete_priv'           => 'Y',
                                        'Create_priv'           => 'Y',
                                        'Drop_priv'             => 'Y',
                                        'Index_priv'            => 'Y',
                                        'Alter_priv'            => 'Y',
                                        'Create_tmp_table_priv' => 'Y',
                                        'Lock_tables_priv'      => 'Y',
                                        'Execute_priv'          => 'Y',
                                        'Create_view_priv'      => 'Y',
                                        'Show_view_priv'        => 'Y',
                                        'Create_routine_priv'   => 'Y',
                                        'Alter_routine_priv'    => 'Y',
                                        'Event_priv'            => 'Y',
                                        'Trigger_priv'          => 'Y'}
            when 'slave'
                if(permission_type == 'database_specific')
                    fail("Unable to set permission '${user_role}' on a specific database.")
                end
                override_permissions = {'Repl_slave_priv' => 'Y'}
            when 'none'
                return default_permissions(permission_type)
            when 'full'
                default_list = default_permissions(permission_type)
                full_permissions = default_list.update(default_list) {|key, value| 'Y'}
                return full_permissions
            else
                fail("Role '#{user_role}' is invalid")
        end
        return default_permissions(permission_type).merge(override_permissions)
    end
end
