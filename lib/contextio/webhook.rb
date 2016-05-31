require 'contextio/api/resource'

class ContextIO
  class Webhook
    include ContextIO::API::Resource

    self.primary_key = :webhook_id
    self.association_name = :webhook

    belongs_to :account
    belongs_to :user

    lazy_attributes :callback_url, :failure_notif_url, :active, :sync_period,
                    :failure, :webhook_id, :filter_to, :filter_from, :filter_cc,
                    :filter_subject, :filter_thread, :filter_new_important,
                    :filter_file_name, :filter_file_revisions,
                    :filter_folder_added, :filter_folder_removed
    private :active, :failure

    def active?
      !!active
    end

    def failure?
      !!failure
    end

    def activate
      api.request(:post, resource_url, active: 1)['success']
    end

    def deactivate
      api.request(:post, resource_url, active: 0)['success']
    end

    def delete
      api.request(:delete, resource_url)['success']
    end
  end
end
