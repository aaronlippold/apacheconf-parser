require 'rubygems'
require 'treetop'
require File.join(File.dirname(__FILE__), 'core_ext/hash_ext')
Treetop.load File.join(File.dirname(__FILE__), "../lib/apacheconf")

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
    if e.respond_to?(:elements) && !e.elements.nil?
      vv = []
      vv << e.elements.collect do |ee|
        (ee.value if ee.respond_to?(:value)) || self.rec_collect(ee, v)
      end
      if !vv.flatten.empty?
        v = vv
      end
    else
      v << e.value if e.respond_to?(:value)
    end
    v
  end

  
  def ast
    ast = @parser.parse self.file_content
    if ast.nil?
      p @parser.failure_reason
      return
    end
    #puts ast
    ast.value
  end
  
end