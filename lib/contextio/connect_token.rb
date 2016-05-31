require 'contextio/api/resource'

class ContextIO
  # Represents a single connect token for an account. You can use this to
  # inspect or delete the token. Most of the attributes are lazily loaded,
  # meaning that the API won't get hit until you ask for an attribute the object
  # doesn't already have (presumably from a previous API call).
  class ConnectToken
    include API::Resource

    self.primary_key = :token
    self.association_name = :connect_token

    # @!attribute [r] account
    #
    # @return [ContextIO::Account, nil] The Account associated with this token,
    #   if any. Will fetch from the API if necessary.
    belongs_to :account
    belongs_to :user

    # @!attribute [r] token
    #   @return [String] The token associated with this connect token. Will
    #     fetch from the API if necessary.
    # @!attribute [r] email
    #   @return [String] The email address associated with this token. Will
    #     fetch from the API if necessary.
    # @!attribute [r] used
    #   @return [Boolean] Whether this token has been used ot not. Will fetch
    #     from the API if necessary.
    # @!attribute [r] callback_url
    #   @return [String] The url that Context.IO will redirect the user to when
    #     the account is created. Will fetch from the API if necessary.
    # @!attribute [r] service_level
    #   @return [String] The Context.IO service level for this account. Will
    #     fetch from the API if necessary.
    # @!attribute [r] first_name
    #   @return [String] The first name of the owner of the email account
    #     associated with this token. Will fetch from the API if necessary.
    # @!attribute [r] last_name
    #   @return [String] The last name of the owner of the email account
    #     associated with this token. Will fetch from the API if necessary.
    lazy_attributes :token, :email, :created, :used, :callback_url,
                    :service_level, :first_name, :last_name
    private :created

    # @!attribute [r] created_at
    #
    # @return [Time] The time this token was created. Will fetch from the API
    #   if necessary.
    def created_at
      @created_at ||= Time.at(created)
    end

    def delete
      api.request(:delete, resource_url)['success']
    end
  end
end
