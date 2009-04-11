require 'rubygems'
require 'treetop'
require File.join(File.dirname(__FILE__), "../lib/apacheconf")

class HttpdconfParser
  def initialize(path = nil)
    @fh = nil
    @file_content = nil
    if !path
      @fh = File.new('/etc/apache/httpd.conf')
    else
      @fh = File.new(path)
    end
    @file_content = @fh.read
    @fh.close    
    @parser = ApacheConfParser.new
  end
    
  def file_content
    @file_content
  end

  def self.rec_collect(e, v = [])
    # recursive collection of elements in a treetop generated
    # syntax tree that respond to the 'value' method (ie: stuff
    # generated by our httpd.conf parser)
    if e.respond_to?(:elements) and !e.elements.nil?
      vv = e.elements.collect do |ee|
        if ee.respond_to?(:value) and !ee.value.nil?
          ee.value  
        else 
          self.rec_collect(ee, v)
        end
      end
      v = vv unless vv.empty? or vv.flatten.empty? 
    else
      v = e.value if e.respond_to?(:value) and !e.value.nil?
    end
    # remove empty arrays
    v.delete_if { |i| i.empty? }
  end

  def ast
    # return the abstract syntax tree or in our case
    # the parsed hash
    ast = @parser.parse self.file_content
    if ast.nil?
      puts @parser.failure_reason
#      p @parser
      return nil
    end
    unless ast.value.nil?
      ast.value
    else 
      []
    end
  end
  
end