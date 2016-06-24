require_relative 'api/resource_collection'
require_relative 'folder'

class ContextIO
  class FolderCollection
    include ContextIO::API::ResourceCollection

    self.resource_class = ContextIO::Folder
    self.association_name = :folders

    belongs_to :source
    belongs_to :email_account

    def create(folder_name, folder_delimiter='/')
      api.request(:put, "#{resource_url}/#{folder_name}", delim: folder_delimiter)['success']
    end
  end
end

