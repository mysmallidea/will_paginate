module WillPaginate
  module Deserializer

    def self.included(base)
      base.extend ClassMethods
      class << base
        alias_method_chain :instantiate_collection, :collection
      end
    end
    
    module ClassMethods
      def paginate(options = {})
        options[:params] = {} unless options[:params]
        options[:params].reverse_merge!(:page => [].paginate.current_page, :per_page => [].paginate.per_page)
        results = find(:all, options)
        results.is_a?(WillPaginate::Collection) ? results : results.paginate(:page => options[:params][:page], :per_page => options[:params][:per_page])
      end
      
      def instantiate_collection_with_collection(collection, prefix_options = {})
        if collection.is_a?(Hash) && collection["type"] == "collection"
          collectables = collection.values.find{|c| c.is_a?(Hash) || c.is_a?(Array) }
          collectables = [collectables].compact unless collectables.kind_of?(Array)
          instantiated_collection = WillPaginate::Collection.create(collection["current_page"], collection["per_page"], collection["total_entries"]) do |pager|
            pager.replace instantiate_collection_without_collection(collectables, prefix_options)
          end          
        else
          instantiate_collection_without_collection(collection, prefix_options)
        end        
      end
    end        
    
  end  
end