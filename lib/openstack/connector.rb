module OpenStack
  class Connector

    # define constant OpenStack::Config as Hash
    # with keys:
    #
    # auth_url: AUTH_URL
    # authtenant_name: TENANT
    # password: PASSWORD
    # user: USERNAME
    # <service>_service_path: SERVICE_PATH (optional)
    #
    # And use 
    # 
    # def connector
    #   OpenStack::Connector.new
    # end
    #
    # connector.compute.security_groups ...
    #
    # for easy connection configuration and openstack-requests


    def initialize(auth_tenant = nil)
      @auth_tenant = auth_tenant
      if defined?(OpenStack::Config)
        raise OpenStack::Exception::ConfigurationMissing.new('Define OpenStack::Config[:user] before using connector') unless OpenStack::Config[:user]
        raise OpenStack::Exception::ConfigurationMissing.new('Define OpenStack::Config[:password] before using connector') unless OpenStack::Config[:password]
        raise OpenStack::Exception::ConfigurationMissing.new('Define OpenStack::Config[:auth_url] before using connector') unless OpenStack::Config[:auth_url]
        raise OpenStack::Exception::ConfigurationMissing.new('Define OpenStack::Config[:authtenant_name] before using connector') unless @auth_tenant || OpenStack::Config[:authtenant_name]
      else
        raise OpenStack::Exception::ConfigurationMissing.new('Define OpenStack::Config before using connector')
      end
    end

    %w(compute identity network metering object-store).each do |service|
      define_method service.gsub('-','_') do
        OpenStack::Connection.create username: OpenStack::Config[:user],
                                     api_key: OpenStack::Config[:password],
                                     auth_method: 'password',
                                     auth_url: OpenStack::Config[:auth_url],
                                     authtenant_name: (@auth_tenant || OpenStack::Config[:authtenant_name]),
                                     default_service_path: OpenStack::Config["#{service}_service_path".to_sym],
                                     ca_file: (OpenStack::Config[:ca_file] || nil),
                                     ssl_version: (OpenStack::Config[:ssl_version] || nil),
                                     service_type: service
      end
    end

  end
end
