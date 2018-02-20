require_relative 'api/resource_collection'
require_relative 'message'

class ContextIO
  class MessageCollection
    include ContextIO::API::ResourceCollection

    self.resource_class = ContextIO::Message
    self.association_name = :messages

    belongs_to :account
    belongs_to :folder

    # You can pass a Folder object and this'll use the source from it, or you
    # can pass a folder label and a source label (from the API), if that's
    # easier for you.
    #
    # This is private because AFAICT, the oauth gem doesn't do POST requests
    # with Content-Type = 'multipart/form-data' easily. I think it might behoove
    # us to replace that dependency in the future, anyway, and we can fix this
    # at that point. In any case, this functionality was missing from previous
    # releases of the contextio gem, too.
    def create(raw_message, folder, source = nil)
      if folder.is_a?(ContextIO::Folder)
        folder_label = folder.name
        source_label = source || folder.source.label
      else
        folder_label = folder.to_s
        source_label = source.to_s
      end

      api.request(:post, resource_url, message: raw_message, dst_folder: folder_label, dst_source: source_label)['success']
    end
    private :create
  end
end
