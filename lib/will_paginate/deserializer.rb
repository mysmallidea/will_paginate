module WillPaginate
  module Deserializer

    def self.included(base)
      base.extend ClassMethods
      class << base
        alias_method_chain :instantiate_collection, :collection
      end
    end
    
    module ClassMethods
      def instantiate_collection_with_collection(collection, prefix_options = {})
        if collection["type"] == "collection"
          collectables = collection.values.find{|c| c.is_a?(Hash) || c.is_a?(Array) }
          collectables = [collectables] unless collectables.kind_of?(Array)
          instantiated_collection = instantiate_collection_without_collection(collectables, prefix_options = {}).paginate(
            :page => collection["current_page"], 
            :per_page => collection["per_page"], 
            :total_entries => collection["total_entries"]
          )
        else
          instantiate_collection_without_collection(collection, prefix_options = {})
        end        
      end
    end        
    
  end  
end