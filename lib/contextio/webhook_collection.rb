require_relative 'api/resource_collection'
require_relative 'webhook'

class ContextIO
  class WebhookCollection
    include ContextIO::API::ResourceCollection

    self.resource_class = ContextIO::Webhook
    self.association_name = :webhooks

    belongs_to :account
    belongs_to :user

    def create(success_callback_url, failure_callback_url, options={})
      api_args = options.merge(
        'callback_url' => success_callback_url,
        'failure_notif_url' => failure_callback_url
      )

      result_hash = api.request(:post, resource_url, api_args)

      result_hash.delete('success')

      resource_class.new(api, result_hash)
    end
  end
end
