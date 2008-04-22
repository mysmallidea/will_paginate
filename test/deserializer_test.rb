require 'helper'
require 'lib/activeresource_test_case'

class DeserializerTest < Test::Unit::TestCase  
  def test_collection_without_entries
    projects_xml = [].paginate(:page => 1, :per_page => 5).to_xml
    
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
    projects_xml = [{:name => "will_paginate" }].paginate(:page => 1, :per_page => 5).to_xml(:root => "projects")
    
    ActiveResource::HttpMock.respond_to do |mock|      
      mock.get "/projects.xml", {}, projects_xml
    end
    
    projects = Client::Project.find(:all) 
    
    assert projects.kind_of?(WillPaginate::Collection)
    
    assert_equal 1, projects.size
    
    assert_equal 1, projects.current_page
    
    assert_equal 5, projects.per_page
    
    assert_equal 1, projects.total_entries    
    
    assert_equal "will_paginate", projects.first.name    
  end
  
  def test_collection_with_multiple_entries
    projects_xml = [{:name => "will_paginate" }, {:name => "active_resource" }].paginate(:page => 1, :per_page => 5).to_xml(:root => "projects")
    
    ActiveResource::HttpMock.respond_to do |mock|      
      mock.get "/projects.xml", {}, projects_xml
    end
    
    projects = Client::Project.find(:all)
    
    assert projects.kind_of?(WillPaginate::Collection)
    
    assert_equal 2, projects.size    
    
    assert_equal 1, projects.current_page
    
    assert_equal 5, projects.per_page
    
    assert_equal 2, projects.total_entries    
    
    assert_equal "active_resource", projects.last.name    
  end
end
