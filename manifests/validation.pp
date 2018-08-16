# @summary Handles the validation of some parameters.
#
# @note
# Certain parameters depend on other parameters or will have a more complex structure, which
# is not easily enforced by using enum's or the like. This class ensures the right values for
# parameters, making the module a bit more user friendly.
#
class mysql::validation{
    if($::mysql::server_type == 'master') or
        ($::mysql::server_type == 'slave'){
        if($::mysql::server_id == undef){
            fail('A server ID needs to be set for MySQL replication')
        }
        if($::mysql::log_expiration == undef){
            fail('Log expiration needs to be set for MySQL replication')
        }
        if($::mysql::binlog_size == undef){
            fail('A maximum binlog size needs to be set for MySQL replication')
        }
        if($::mysql::replicate_db == undef){
            fail('At least one replication database needs to be set for MySQL replication')
        }
    }

    if($::mysql::server_type == 'master'){
        if($::mysql::log_bin == undef){
            fail('A binary log needs to be set for MySQL replication')
        }
    }

    if($::mysql::enable_ssl){
        if($::mysql::ssl_ca_cert == undef){
            fail('A SSL CA certificate is needed for SSL support')
        }
        if($::mysql::ssl_cert == undef){
            fail('A SSL certificate is needed for SSL support')
        }
        if($::mysql::ssl_key == undef){
            fail('A SSL private key is needed for SSL support')
        }
    }

    if($::mysql::users){
        $::mysql::users.each |Hash $user|{
            if($user['name'] == 'root'){
                fail('The root user is managed through its own class')
            }
        }
    }
}
