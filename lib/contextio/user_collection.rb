require_relative 'api/resource_collection'
require_relative 'user'

class ContextIO
  # Represents a collection of email accounts for your Context.IO account. You
  # can use this to add a new one to your account, iterate over them, or fetch a
  # specific one.
  #
  # You can also limit which accounts belongin the collection using the `where`
  # method. Valid keys are: email, status, status_ok, limit and offset. See
  # [the Context.IO documentation](http://context.io/docs/2.0/accounts#get) for
  # more explanation of what each key means.
  #
  # @example You can iterate over them with `each`:
  #   contextio.accounts.each do |accounts|
  #     puts account.email_addresses
  #   end
  #
  # @example You can lazily access a specific one with square brackets:
  #   account = contextio.accounts['some id']
  #
  # @example Lazily limit based on a hash of criteria with `where`:
  #   disabled_accounts = contextio.accounts.where(status: 'DISABLED')
  class UserCollection
    include ContextIO::API::ResourceCollection

    self.resource_class = ContextIO::User
    self.association_name = :users

    # Creates a new email account for your Context.IO account.
    #
    # @param [Hash{String, Symbol => String}] options Information you can
    #   provide at creation: email, first_name and/or last_name. If the
    #   collection isn't already limited by email, then you must provide it.
    #
    # @return [User] A new email account instance based on the data you
    #   input.
    def create(options={})
      email = options.delete(:email) || options.delete('email') ||
        where_constraints[:email] || where_constraints['email']

      if email.nil?
        raise ArgumentError, "You must provide an email for new Users."
      end

      result_hash = api.request(
        :post,
        resource_url,
        options.merge(email: email)
      )

      result_hash.delete('success')

      resource_class.new(api, result_hash)
    end
  end
end
