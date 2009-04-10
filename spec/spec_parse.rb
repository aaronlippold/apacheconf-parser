require 'rubygems'
require 'spec'
require 'spec/expectations'
require 'treetop'
require File.join(File.dirname(__FILE__), "../lib/httpdconf_parser")


describe HttpdconfParser do
  before(:each) do
    @file_content = %{
      <VirtualHost 10.10.10.1:443>
        ServerName test.co.za
        ServerAlias www.test.co.za
        DocumentRoot /usr/www/users/test
        <Directory /usr/www/users/test>
          Options blah blah
        </Directory>
      <VirtualHost>
    }
    
    @fh = mock("File", :null_object => true)
    File.should_receive(:new).with("/etc/apache/httpd.conf").and_return(@fh)
  end

  it "should open httpd.conf in its default location on debian servers" do
    parser = HttpdconfParser.new
  end
  
  it "should read the content of the httpd.conf file into memory" do
    @fh.should_receive(:read).and_return(@file_content)
    parser = HttpdconfParser.new
    parser.file_content.should == @file_content
  end
  
  it "should parse a directive into a hash" do
    @file_content = "Options Indexes Includes FollowSymLinks ExecCGI"
    @fh.should_receive(:read).and_return(@file_content)
    parser = HttpdconfParser.new
    parser.ast.should == [{:Options => ['Indexes', 'Includes', 'FollowSymLinks', 'ExecCGI'] }]
  end
  
  it "should parse a directory entry into a hash" do
    @file_content = "<Directory /usr/www/users/blah>
      Options Indexes Includes FollowSymLinks ExecCGI
    </Directory>"
    @fh.should_receive(:read).and_return(@file_content)
    parser = HttpdconfParser.new
    parser.ast.should == 
    [{:directory=>"/usr/www/users/blah", 
      :entries=>
      [ 
        {:Options=>["Indexes", "Includes", "FollowSymLinks", "ExecCGI"]}
      ]
     }
    ]
  end

  it "should parse a vhost entry into a hash" do
    file_content = "
    ServerName blah.co.za
    Options some options
    <VirtualHost 10.10.10.2:123>
      ServerName www.test123.co.za
      ServerAlias www1.test123.co.za
      ServerAlias www2.test123.co.za
      DocumentRoot /usr/www/users/blah
      <Directory /usr/www/users/blah>
        Options Indexes Includes FollowSymLinks ExecCGI
      </Directory>
    </VirtualHost>"
    @fh.should_receive(:read).and_return(file_content)
    parser = HttpdconfParser.new
    parser.ast.should == 
    [
      {:ServerName=>["blah.co.za"]}, 
      {:Options=>["some", "options"]}, 
      {:port=>123, :ip_addr=>[10, 10, 10, 2], :entries=>
        [
          {:ServerName=>["www.test123.co.za"]}, 
          {:ServerAlias=>["www1.test123.co.za"]}, 
          {:ServerAlias=>["www2.test123.co.za"]}, 
          {:DocumentRoot=>["/usr/www/users/blah"]}, 
          {:directory=>"/usr/www/users/blah", :entries=>
            [
              {:Options=>["Indexes", "Includes", "FollowSymLinks", "ExecCGI"]}
            ]
          }
        ]
      }
    ]
  end
    
end