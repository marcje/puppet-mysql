# @summary Creates MySQL queries for managing MySQL user permissions.
Puppet::Functions.create_function(:'mysql::generate_query') do
    # @param query_type
    #   The type of the query to generate.
    # @param user
    #   The name of the MySQL user to use.
    # @param host
    #   The host the user will be able to connect from.
    # @param permission_list
    #   The permission list in hash format to generate a query from.
    # @param extend_select
    #   Whether to extend the WHERE clause of the SELECT query with the permission list values.
    # @param database
    #   The name of the database when setting database specific permissions.
    # @return [String] A string containing the generated query.
    # @raise PuppetError When an incorrect query_type is given.
    # @raise PuppetError When trying to generate an INSERT query for global user permissions.
    # @note
    # In order to easily generate queries from the permission list this function has been created.
    # The INSERT query can only be generated for database specific permissions, because the global
    # user permissions are only updated. INSERTS (and DELETES for that matter) on users are managed
    # by managing the user itself, rather than its permissions.
    dispatch :generate do
        required_param "Enum['select',
                             'insert',
                             'update']",    :query_type
        required_param 'String',            :user
        required_param 'String',            :host
        required_param 'Hash',              :permission_list
        optional_param 'Boolean',           :extend_select
        optional_param 'String',            :database
        return_type 'String'
    end

    public
    def generate(query_type, user, host, permission_list, extend_select=false, database=nil)
        if database
            table = "mysql.db"
            where_values = "User='#{user}' AND Host='#{host}' AND Db='#{database}'"
        else
            table = "mysql.user"
            where_values = "User='#{user}' AND Host='#{host}'"
        end

        case query_type
        when 'select'
            if extend_select
                where_values += "AND " + permission_list.map{|key, value| "#{key}='#{value}'"}.join("AND ")
            end  
           return "SELECT User, Host FROM #{table} WHERE #{where_values};"
        when 'insert'
            unless database
                fail("The value '#{query_type}' can only be used for database specific queries.")
            end
            insert_columns = (['Host', 'Db', 'User'] + permission_list.keys).join(", ")
            insert_values = (["'#{host}'", "'#{database}'", "'#{user}'"] + permission_list.map{|key, value| "'#{value}'"}).join(", ")
            return "INSERT INTO #{table} (#{insert_columns}) VALUES (#{insert_values});"
        when 'update'
            set_values = permission_list.map{|key, value| "#{key}='#{value}'"}.join(", ")
            return "UPDATE #{table} SET #{set_values} WHERE #{where_values};"
        else
            fail("The value '#{query_type}' is not a valid query_type.")
        end
    end
end
