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
    
    @big_vhentry = %{
      <VirtualHost 41.204.202.32> 
          ServerAdmin webmaster@hrworks.co.za
          ServerName hrworks.co.za
          ServerAlias www.hrworks.co.za 
          ServerAlias hrworks.co.za.* 
          DocumentRoot /usr/www/users/hrworke
          php_admin_value open_basedir /usr/www/users/hrworke:/usr/home/hrworke:/tmp:/usr/share/php
          php_admin_value allow_url_fopen Off
          # hos_config 
          <Directory "/usr/www/users/hrworke"> 
              Options Indexes Includes FollowSymLinks ExecCGI
              AddHandler php-script .php5
              Action php-script /cgi-sys/php5
              AddType application/x-httpd-php .php .php3 .php4
              Action application/x-httpd-php5 /cgi-sys/php5
              AddType application/x-httpd-php5 .php5
          </Directory>
          # hos_config 
      </VirtualHost>
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
  
  # it "should parse valid minimal vhosts without error" do
  #   @file_content = "<VirtualHost 10.20.30.10:123>        \n\n
  #       ServerName test123.co.za
  #       ServerAlias www.test123.co.za
  #       ServerAlias www2.test123.co.za
  #       DocumentRoot /usr/www/users/test
  #   </VirtualHost>"
  #   @fh.should_receive(:read).and_return(@file_content)
  #   parser = HttpdconfParser.new
  #   parser.ast.should == {:header=>{:port=>"123", 
  #                                   :ip_addr=>"10.20.30.10"}, 
  #                         :servername=>"test123.co.za", :directives=>{:serveralias=>["www.test123.co.za", "www2.test123.co.za"],
  #                                                                     :servername=>"test123.co.za", 
  #                                                                     :documentroot=>"/usr/www/users/test"}}
  # end
  # 
  # it "should parse valid minimal directory entries without error" do
  #   @file_content = "<VirtualHost 10.20.30.10:123>        \n\n
  #     ServerName test123.co.za
  #   <Directory /usr/www/users/blah>
  #     Options Indexes Includes FollowSymLinks ExecCGI
  #   </Directory>
  #   </VirtualHost>"
  #   @fh.should_receive(:read).and_return(@file_content)
  #   parser = HttpdconfParser.new
  #   parser.ast.should == {:directory => "/usr/www/users/blah", :directives => {:options => ['Indexes', 'Includes', 'FollowSymLinks', 'ExecCGI']}} 
  # end
  
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