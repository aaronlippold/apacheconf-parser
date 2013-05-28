# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "apacheconf-parser"
  s.version     = "0.0.1"
  s.authors     = ["Wynand van Dyk"]
  s.email       = ["wvandyk@gmail.com"]
  s.homepage    = "https://github.com/vleis/apacheconf-parser"
  s.summary     = %q{Apache http.conf parser}
  s.description = %q{}

  s.rubyforge_project = "apacheconf-parser"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "test-spec"
  s.add_runtime_dependency "treetop"
end
