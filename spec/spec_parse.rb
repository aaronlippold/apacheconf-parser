require 'rubygems'
require 'spec'
require 'spec/expectations'
require 'treetop'
require File.join(File.dirname(__FILE__), "../lib/httpdconf_parser")


describe HttpdconfParser do
  context "general parser machinery" do
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
  
    it "should allow the port specification in a virtualhost header to be optional" do
      file_content = "<VirtualHost 10.11.12.13></VirtualHost>"
      @fh.should_receive(:read).and_return(file_content)
      parser = HttpdconfParser.new
      parser.ast.should == [{:entries=>[], :ip_addr=>[10, 11, 12, 13]}]
    end

    it "should ignore comments" do
      file_content = "# this is a comment"
      @fh.should_receive(:read).and_return(file_content)
      parser = HttpdconfParser.new
      parser.ast.should == []
    end

    it "should parse a vhost entry into a hash" do
      file_content = "
      ServerName blah.co.za
      Options some options
      # lets add a comment here
      <VirtualHost 10.10.10.2:123>
        ServerName www.test123.co.za
        ServerAlias www1.test123.co.za
        ServerAlias www2.test123.co.za
        DocumentRoot /usr/www/users/blah
        <Directory /usr/www/users/blah>
          # and another comment goes here   
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
  # end
  # 
  # context "httpd.conf file from www32" do
    it "should parse an entire httpd.conf file" do
      # path = '/Users/wvd/work/parse_httpd.conf/httpd.conf'
      file_content = %{
        ServerRoot "/etc/apache"
        ResourceConfig /etc/apache/srm.conf
        AccessConfig /etc/apache/access.conf

        Port 80
        include /etc/apache/httpd.conf_main
        include /etc/apache/mod_gzip.conf




        ### Section 3: Virtual Hosts


        #




        # VirtualHost: If you want to maintain multiple domains/hostnames on your
        # machine you can setup VirtualHost containers for them.
        # Please see the documentation at <URL:http://www.apache.org/docs/vhosts/>
        # for further details before you try to setup virtual hosts.
        # You may use the command line option '-S' to verify your virtual host
        # configuration.

        #
        # If you want to use name-based virtual hosts you need to define at
        # least one IP address (and port number) for them.
        #
        #NameVirtualHost 12.34.56.78:80
      }
      @fh.should_receive(:read).and_return(file_content)
      parser = HttpdconfParser.new
      # puts parser.file_content
      parser.ast.should == {}
    end

  end
    
end