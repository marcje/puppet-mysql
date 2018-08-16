# @summary Fetches the current root password from the MySQL server.
#
# @return [String]
#  Returns either the current root password from file
#  or an empty string if the file can not be found or read.
#
Facter.add('mysql_current_root_password') do
	setcode do
        begin
		    File.read("/root/.mysql_password").strip()
        rescue
            ''
        end
	end
end
