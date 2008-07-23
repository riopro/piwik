Gem::Specification.new do |s|
  s.name = %q{piwik}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rodrigo Tassinari de Oliveira @ Riopro Inform\303\241tica Ltda"]
  s.date = %q{2008-07-23}
  s.description = %q{A simple Ruby client for the Piwik API}
  s.email = ["roliveira@riopro.com.br"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "PostInstall.txt", "README.txt", "Todo.txt", "website/index.txt"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "PostInstall.txt", "README.txt", "Rakefile", "Todo.txt", "config/hoe.rb", "config/requirements.rb", "lib/piwik.rb", "lib/piwik/base.rb", "lib/piwik/site.rb", "lib/piwik/user.rb", "lib/piwik/version.rb", "script/console", "script/destroy", "script/generate", "script/txt2html", "setup.rb", "spec/piwik_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/deployment.rake", "tasks/environment.rake", "tasks/rspec.rake", "tasks/website.rake", "website/index.html", "website/index.txt", "website/javascripts/rounded_corners_lite.inc.js", "website/stylesheets/screen.css", "website/template.html.erb"]
  s.has_rdoc = true
  s.homepage = %q{http://piwik.rubyforge.org}
  s.post_install_message = %q{
For more information on piwik, see http://piwik.rubyforge.org or 
http://github.com/riopro/piwik/

}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{piwik}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A simple Ruby client for the Piwik API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<activesupport>, [">= 1.4.4"])
      s.add_runtime_dependency(%q<rest-client>, [">= 0.5.1"])
      s.add_runtime_dependency(%q<xml-simple>, [">= 1.0.11"])
    else
      s.add_dependency(%q<activesupport>, [">= 1.4.4"])
      s.add_dependency(%q<rest-client>, [">= 0.5.1"])
      s.add_dependency(%q<xml-simple>, [">= 1.0.11"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 1.4.4"])
    s.add_dependency(%q<rest-client>, [">= 0.5.1"])
    s.add_dependency(%q<xml-simple>, [">= 1.0.11"])
  end
end
