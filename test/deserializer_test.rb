require 'helper'
require 'lib/activeresource_test_case'

class DeserializerTest < Test::Unit::TestCase  
  def test_collection_without_entries
    collection = create(1, 5, 0)
    projects_xml = collection.to_xml
    
    ActiveResource::HttpMock.respond_to do |mock|      
      mock.get "/projects.xml", {}, projects_xml
    end
    
    projects = Client::Project.find(:all) 
    
    assert projects.kind_of?(WillPaginate::Collection)
    
    assert_equal 0, projects.size
    
    assert_equal 1, projects.current_page
    
    assert_equal 5, projects.per_page
    
    assert_equal 0, projects.total_entries    
    
    assert_equal nil, projects.first
  end
    
  def test_collection_with_one_entry
    collection = create(1, 5, 1337) {|pager| pager.replace([{:name => "will_paginate" }]) }
    projects_xml = collection.to_xml(:root => "projects")
    
    ActiveResource::HttpMock.respond_to do |mock|      
      mock.get "/projects.xml", {}, projects_xml
    end
    
    projects = Client::Project.find(:all) 
    
    assert projects.kind_of?(WillPaginate::Collection)
    
    assert_equal 1, projects.size
    
    assert_equal 1, projects.current_page
    
    assert_equal 5, projects.per_page
    
    assert_equal 1337, projects.total_entries    
    
    assert_equal "will_paginate", projects.first.name    
  end
  
  def test_collection_with_multiple_entries
    collection = create(1, 5, 1337) {|pager| pager.replace([{:name => "will_paginate" }, {:name => "active_resource" }]) }
    projects_xml = collection.to_xml(:root => "projects")
    
    ActiveResource::HttpMock.respond_to do |mock|      
      mock.get "/projects.xml", {}, projects_xml
    end
    
    projects = Client::Project.find(:all)
    
    assert projects.kind_of?(WillPaginate::Collection)
    
    assert_equal 2, projects.size    
    
    assert_equal 1, projects.current_page
    
    assert_equal 5, projects.per_page
    
    assert_equal 1337, projects.total_entries    
    
    assert_equal "active_resource", projects.last.name    
  end
  
  def test_collection_on_next_page_within_total
    collection = create(2, 1, 1337) {|pager| pager.replace([{:name => "will_paginate" }]) }
    projects_xml = collection.to_xml(:root => "projects")
    
    ActiveResource::HttpMock.respond_to do |mock|      
      mock.get "/projects.xml", {}, projects_xml
    end
    
    projects = Client::Project.find(:all)
    
    assert projects.kind_of?(WillPaginate::Collection)
    
    assert_equal 1, projects.size    
    
    assert_equal 2, projects.current_page
    
    assert_equal 1, projects.per_page
    
    assert_equal 1337, projects.total_entries    
    
    assert_equal "will_paginate", projects.first.name    
  end
  
  def test_collection_on_next_page_outside_of_total
    collection = create(2, 2, 1337) {|pager| pager.replace([{:name => "will_paginate" }, {:name => "active_resource" }]) }
    projects_xml = collection.to_xml(:root => "projects")
    
    ActiveResource::HttpMock.respond_to do |mock|      
      mock.get "/projects.xml", {}, projects_xml
    end
    
    projects = Client::Project.find(:all)
    
    assert projects.kind_of?(WillPaginate::Collection)
    
    assert_equal 2, projects.size    
    
    assert_equal 2, projects.current_page
    
    assert_equal 2, projects.per_page
    
    assert_equal 1337, projects.total_entries    
    
    assert_equal "active_resource", projects.last.name    
  end
private
  def create(page = 2, limit = 5, total = nil, &block)
    if block_given?
      WillPaginate::Collection.create(page, limit, total, &block)
    else
      WillPaginate::Collection.new(page, limit, total)
    end
  end  
end
