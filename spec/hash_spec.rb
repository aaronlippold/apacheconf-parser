require 'rubygems'
require 'spec'
require 'spec/expectations'

require File.join(File.dirname(__FILE__), "../lib/core_ext/hash_ext")

describe Hash do
  it "should respond to a function named add_without_overwrite" do
    h = Hash.new
    h.respond_to?(:add_without_overwrite).should == true
  end
  
  context "function add_without_overwrite" do
    it "should take a key and a value and add that to a hash" do
      h = {:test => 'abc', :numbers => '123'}
      h.add_without_overwrite(:lolcats, 'funny')
      h.should == {:test => 'abc', :numbers => '123', :lolcats => 'funny'}
    end
    
    it "should add values to a key as an array if the key already exists, eg: :key => [value1, value2]" do
      h = {:test => 'abc', :numbers => '123'}
      h.add_without_overwrite(:test, 'funny')
      h.should == {:test => ['abc', 'funny'], :numbers => '123'}
    end
  end
end