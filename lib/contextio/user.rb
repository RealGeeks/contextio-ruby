require 'contextio/api/resource'
require 'contextio/api/association_helpers'
require 'contextio/account_sync_data'

class ContextIO
  class User
    include ContextIO::API::Resource

    self.primary_key = :id
    self.association_name = :account

    has_many :sources
    has_many :connect_tokens
    has_many :messages
    has_many :threads
    has_many :webhooks

    has_many :files

    # @!attribute [r] id
    #   @return [String] The id assigned to this account by Context.IO.
    # @!attribute [r] username
    #   @return [String] The username assigned to this account by Context.IO.
    # @!attribute [r] first_name
    #   @return [String] The account holder's first name.
    # @!attribute [r] last_name
    #   @return [String] The account holder's last name.
    lazy_attributes :id, :username, :created, :suspended, :first_name,
                    :last_name, :password_expired, :nb_messages, :nb_files
    private :created, :suspended, :password_expired

    def email_addresses
      # It would be nice if the data returned from the API were formatted like
      # other resources, but it isn't. So hacks.
      @email_addresses = nil if @email_addresses.is_a?(Array)

      return @email_addresses if @email_addresses

      association_class = ContextIO::API::AssociationHelpers.class_for_association_name(:email_addresses)

      reconstructed_email_hashes = api_attributes['email_addresses'].collect do |addy|
        {'email' => addy}
      end

      @email_addresses = association_class.new(
        api,
        self.class.association_name => self,
        attribute_hashes: reconstructed_email_hashes
      )
    end

    # @!attribute [r] created_at
    #   @return [Time] The time this account was created (with Context.IO).
    def created_at
      @created_at ||= Time.at(created)
    end

    # @!attribute [r] suspended_at
    #   @return [Time] The time this account was suspended.
    def suspended_at
      return @suspended_at if instance_variable_defined?(:@suspended_at)

      @suspended_at = suspended == 0 ? nil : Time.at(suspended)

      @suspended_at
    end

    # @!attribute [r] suspended?
    #   @return [Boolean] Whether this account is currently suspended.
    def suspended?
      !!suspended_at
    end

    # @!attribute [r] password_expired_at
    #   @return [Time] The time this account's password expired.
    def password_expired_at
      return @password_expired_at if instance_variable_defined?(:@password_expired_at)

      @password_expired_at = password_expired == 0 ? nil : Time.at(password_expired)

      @password_expired_at
    end

    # @!attribute [r] password_expired?
    #   @return [Boolean] Whether this account's password is expired.
    def password_expired?
      !!password_expired_at
    end

    # Updates the account.
    #
    # @param [Hash{String, Symbol => String}] options You can update first_name
    #   or last_name (or both).
    def update(options={})
      first_name = options[:first_name] || options['first_name']
      last_name = options[:last_name] || options['last_name']

      attrs = {}
      attrs[:first_name] = first_name if first_name
      attrs[:last_name] = last_name if last_name

      return nil if attrs.empty?

      it_worked = api.request(:post, resource_url, attrs)['success']

      if it_worked
        @first_name = first_name || @first_name
        @last_name = last_name || @last_name
      end

      it_worked
    end

    def sync_data
      return @sync_data if @sync_data

      sync_hashes = api.request(:get, "#{resource_url}/sync")

      @sync_data = ContextIO::AccountSyncData.new(sync_hashes)

      return @sync_data
    end

    def sync!(options={})
      api.request(:post, "#{resource_url}/sync", options)['success']
    end

    def delete
      api.request(:delete, resource_url)['success']
    end
  end
end
