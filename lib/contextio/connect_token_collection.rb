require_relative 'connect_token'
require_relative 'api/resource_collection'

class ContextIO
  # Represents a collection of connect tokens for your account. You can use this
  # to create a new token, fetch a specific one or iterate over them.
  #
  # @example You can iterate over them with `each`:
  #   contextio.connect_tokens.each do |connect_token|
  #     puts connect_token.email
  #   end
  #
  # @example You can lazily access a specific one with square brackets:
  #   connect_token = contextio.connect_tokens['some_token']
  class ConnectTokenCollection
    include ContextIO::API::ResourceCollection

    self.resource_class = ContextIO::ConnectToken
    self.association_name = :connect_tokens

    belongs_to :account
    belongs_to :user

    # Creates a new connect token for your account.
    #
    # @param [String] callback_url The url that the user will be redirected to
    #   after OAuthing their account with Context.IO.
    # @param [Hash{String, Symbol => String}] options Optional information you
    #   can provide at creation: email, service level, first_name and/or
    #   last_name.
    #
    # @return [ConnectToken] A new token instance based on the data you input.
    def create(callback_url, options={})
      result_hash = api.request(
        :post,
        resource_url,
        options.merge(callback_url: callback_url)
      )

      result_hash.delete('success')

      resource_class.new(api, result_hash)
    end
  end
end
