require 'contextio/connect_token_collection'
require 'contextio/oauth_provider_collection'
require 'contextio/email_settings'
require 'contextio/account_collection'
require 'contextio/user_collection'
require 'contextio/source_collection'
require 'contextio/email_account_collection'
require 'contextio/folder_collection'
require 'contextio/message_collection'
require 'contextio/body_part_collection'
require 'contextio/thread_collection'
require 'contextio/webhook_collection'
require 'contextio/email_address_collection'
require 'contextio/contact_collection'
require 'contextio/file_collection'

class ContextIO
  class API
    class URLBuilder
      class Error < StandardError; end

      # Tells you the right URL for a resource to fetch attributes from.
      #
      # @param [ContextIO::Resource, ContextIO::ResourceCollection] resource The
      #   resource or resource collection.
      #
      # @return [String] The path for that resource in the API.
      def self.url_for(resource)
        if (builder = @registered_urls[resource.class])
          builder.call(resource)
        else
          raise Error, "URL could not be built for unregistered Class: #{resource.class}."
        end
      end

      # Register a block that calculates the URL for a given resource.
      #
      # @param [Class] resource_class The class of the resource you are
      #   registering.
      # @param [Block] block The code that will compute the url for the
      #   resource. This is actually a path. Start after the version number of
      #   the API in the URL. When a URL is being calculated for a specific
      #   resource, the resource instance will be yielded to the block.
      #
      # @example For Accounts
      #   register_url ContextIO::Account do |account|
      #     "accounts/#{account.id}"
      #   end
      def self.register_url(resource_class, &block)
        @registered_urls ||= {}
        @registered_urls[resource_class] = block
      end

      register_url ContextIO::ConnectToken do |connect_token|
        "connect_tokens/#{connect_token.token}"
      end

      register_url ContextIO::ConnectTokenCollection do |connect_tokens|
        if connect_tokens.account && connect_tokens.account.id
          "accounts/#{connect_tokens.account.id}/connect_tokens"
        elsif connect_tokens.user && connect_tokens.user.id
          "users/#{connect_tokens.user.id}/connect_tokens"
        else
          'connect_tokens'
        end
      end

      register_url ContextIO::OAuthProvider do |oauth_provider|
        "oauth_providers/#{oauth_provider.provider_consumer_key}"
      end

      register_url ContextIO::OAuthProviderCollection do
        'oauth_providers'
      end

      register_url ContextIO::EmailSettings do
        'discovery'
      end

      register_url ContextIO::Account do |account|
        "accounts/#{account.id}"
      end

      register_url ContextIO::AccountCollection do
        'accounts'
      end

      register_url ContextIO::User do |user|
        "accounts/#{user.id}"
      end

      register_url ContextIO::UserCollection do
        'users'
      end

      register_url ContextIO::EmailAccount do |email_account|
        "users/#{email_account.user.id}/email_accounts/#{email_account.label}"
      end

      register_url ContextIO::EmailAccountCollection do |email_accounts|
        "users/#{email_account.user.id}/email_accounts"
      end

      register_url ContextIO::Source do |source|
        "accounts/#{source.account.id}/sources/#{source.label}"
      end

      register_url ContextIO::SourceCollection do |sources|
        "accounts/#{sources.account.id}/sources"
      end

      register_url ContextIO::FolderCollection do |folders|
        if folders.source && folders.source.account && folders.source.account.id
          "accounts/#{folders.source.account.id}/sources/#{folders.source.label}/folders"
        elsif folders.email_account && folders.email_account.user && folders.email_account.user.id
          "users/#{folders.email_account.user.id}/email_accounts/#{folders.email_account.label}/folders"
        end
      end

      register_url ContextIO::Folder do |folder|
        if folder.source && folder.source.account && folder.source.account.id
          "accounts/#{folder.source.account.id}/sources/#{folder.source.label}/folders/#{folder.name}"
        elsif folder.email_account && folder.email_account.user && folder.email_account.user.id
          "users/#{folder.email_account.user.id}/email_accounts/#{folder.email_account.label}/folders/#{folder.name}"
        end
      end

      register_url ContextIO::Message do |message|
        if api.version == '2.0'
          "accounts/#{message.account.id}/messages/#{message.message_id}"
        elsif api.version == 'lite' && message.try(:folder).try(:email_account).try(:user).try(:id)
          url = "users/#{message.folder.email_account.user.id}/"
          url += "email_accounts/#{message.folder.email_account.label}/"
          url += "folders/#{message.folder}/"
          url += "messages/#{message.message_id}"
        end
      end

      register_url ContextIO::MessageCollection do |messages|
        if messages.account && messages.account.id
          "accounts/#{messages.account.id}/messages"
        elsif messages.try(:folder).try(:email_account).try(:user).try(:id)
          url = "users/#{message.folder.email_account.user.id}/"
          url += "email_accounts/#{message.folder.email_account.label}/"
          url += "folders/#{message.folder}/"
          url += "messages"
        end
      end

      register_url ContextIO::BodyPartCollection do |parts|
        "accounts/#{parts.message.account.id}/messages/#{parts.message.message_id}/body"
      end

      register_url ContextIO::Thread do |thread|
        "accounts/#{thread.account.id}/threads/#{thread.gmail_thread_id}"
      end

      register_url ContextIO::ThreadCollection do |threads|
        "accounts/#{threads.account.id}/threads"
      end

      register_url ContextIO::Webhook do |webhook|
        if webhook.account && webhook.account.id
          "accounts/#{webhook.account.id}/webhooks/#{webhook.webhook_id}"
        elsif webhook.user && webhook.user.id
          "users/#{webhook.user.id}/webhook/#{webhook.webhook_id}"
        end
      end

      register_url ContextIO::WebhookCollection do |webhooks|
        if webhooks.account && webhooks.account.id
          "accounts/#{webhooks.account.id}/webhooks"
        elsif webhooks.user && webhooks.user.id
          "users/#{webhooks.user.id}/webhooks"
        end
      end

      register_url ContextIO::EmailAddress do |email_address|
        "accounts/#{email_address.account.id}/email_addresses/#{email_address.email}"
      end

      register_url ContextIO::EmailAddressCollection do |email_addresses|
        "accounts/#{email_addresses.account.id}/email_addresses"
      end

      register_url ContextIO::Contact do |contact|
        "accounts/#{contact.account.id}/contacts/#{contact.email}"
      end

      register_url ContextIO::ContactCollection do |contacts|
        "accounts/#{contacts.account.id}/contacts"
      end

      register_url ContextIO::File do |file|
        "accounts/#{file.account.id}/files/#{file.file_id}"
      end

      register_url ContextIO::FileCollection do |files|
        "accounts/#{files.account.id}/files"
      end
    end
  end
end
