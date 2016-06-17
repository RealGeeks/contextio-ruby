require 'contextio/api/association_helpers'

class ContextIO
  class EmailAccount
    include ContextIO::API::Resource

    self.primary_key = :label
    self.association_name = :email_account

    belongs_to :user
    has_many :folders
    has_many :connect_tokens

    lazy_attributes :server, :label, :username, :port, :authentication_type,
                    :status, :sync_period, :use_ssl, :type
    private :use_ssl

    def use_ssl?
      use_ssl
    end
  end
end
