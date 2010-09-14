# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{plist4r}
  s.version = "1.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["dreamcat4"]
  s.date = %q{2010-09-14}
  s.default_executable = %q{plist4r}
  s.description = %q{Plist4r is for editing Plist files in an easy-to-use, fast, and reliabile way. A comprehensive and fully featured Ruby library. Xml and Binary file formats are supported, with backends for Linux and Mac.}
  s.email = %q{dreamcat4@gmail.com}
  s.executables = ["plist4r"]
  s.extensions = ["ext/osx_plist/extconf.rb"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".gitignore",
    ".nojekyll",
    ".yardopts",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/plist4r",
    "ext/osx_plist/extconf.rb",
    "ext/osx_plist/plist.c",
    "features/plist4r.feature",
    "features/step_definitions/plist4r_steps.rb",
    "features/support/env.rb",
    "lib/plist4r.rb",
    "lib/plist4r/application.rb",
    "lib/plist4r/backend.rb",
    "lib/plist4r/backend/c_f_property_list.rb",
    "lib/plist4r/backend/c_f_property_list/LICENSE",
    "lib/plist4r/backend/c_f_property_list/README",
    "lib/plist4r/backend/c_f_property_list/cfpropertylist.rb",
    "lib/plist4r/backend/c_f_property_list/rbBinaryCFPropertyList.rb",
    "lib/plist4r/backend/c_f_property_list/rbCFPlistError.rb",
    "lib/plist4r/backend/c_f_property_list/rbCFPropertyList.rb",
    "lib/plist4r/backend/c_f_property_list/rbCFTypes.rb",
    "lib/plist4r/backend/c_f_property_list/rbXMLCFPropertyList.rb",
    "lib/plist4r/backend/example.rb",
    "lib/plist4r/backend/haml.rb",
    "lib/plist4r/backend/libxml4r.rb",
    "lib/plist4r/backend/osx_plist.rb",
    "lib/plist4r/backend/ruby_cocoa.rb",
    "lib/plist4r/backend/test/data_types.rb",
    "lib/plist4r/backend/test/harness.rb",
    "lib/plist4r/backend/test/output.rb",
    "lib/plist4r/backend_base.rb",
    "lib/plist4r/cli.rb",
    "lib/plist4r/commands.rb",
    "lib/plist4r/config.rb",
    "lib/plist4r/docs/Backends.html",
    "lib/plist4r/docs/DeveloperGuide.rdoc",
    "lib/plist4r/docs/EditingPlistFiles.rdoc",
    "lib/plist4r/docs/InfoPlistExample.rdoc",
    "lib/plist4r/docs/LaunchdPlistExample.rdoc",
    "lib/plist4r/docs/PlistKeyNames.rdoc",
    "lib/plist4r/mixin/array_dict.rb",
    "lib/plist4r/mixin/data_methods.rb",
    "lib/plist4r/mixin/haml4r.rb",
    "lib/plist4r/mixin/haml4r/css_attributes.rb",
    "lib/plist4r/mixin/haml4r/examples.rb",
    "lib/plist4r/mixin/haml4r/haml_table_example.rb",
    "lib/plist4r/mixin/haml4r/table.rb",
    "lib/plist4r/mixin/haml4r/table_cell.rb",
    "lib/plist4r/mixin/haml4r/table_cells.rb",
    "lib/plist4r/mixin/haml4r/table_section.rb",
    "lib/plist4r/mixin/mixlib_cli.rb",
    "lib/plist4r/mixin/mixlib_config.rb",
    "lib/plist4r/mixin/ordered_hash.rb",
    "lib/plist4r/mixin/popen4.rb",
    "lib/plist4r/mixin/ruby_stdlib.rb",
    "lib/plist4r/mixin/script.rb",
    "lib/plist4r/mixin/table.rb",
    "lib/plist4r/plist.rb",
    "lib/plist4r/plist_cache.rb",
    "lib/plist4r/plist_type.rb",
    "lib/plist4r/plist_type/info.rb",
    "lib/plist4r/plist_type/launchd.rb",
    "lib/plist4r/plist_type/plist.rb",
    "plist4r.gemspec",
    "spec/launchd_examples.rb",
    "spec/plist4r/application_spec.rb",
    "spec/plist4r/backend_spec.rb",
    "spec/plist4r/cli_spec.rb",
    "spec/plist4r/commands_spec.rb",
    "spec/plist4r/config_spec.rb",
    "spec/plist4r/mixin/array_dict_spec.rb",
    "spec/plist4r/mixin/data_methods_spec.rb",
    "spec/plist4r/mixin/haml4r/examples.rb",
    "spec/plist4r/mixin/ruby_stdlib_spec.rb",
    "spec/plist4r/plist_cache_spec.rb",
    "spec/plist4r/plist_spec.rb",
    "spec/plist4r/plist_type_spec.rb",
    "spec/plist4r_spec.rb",
    "spec/scratchpad.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/dreamcat4/plist4r}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Dreamcat4's plist4r gem. For reading/writing plists in ruby}
  s.test_files = [
    "spec/launchd_examples.rb",
    "spec/plist4r/application_spec.rb",
    "spec/plist4r/backend_spec.rb",
    "spec/plist4r/cli_spec.rb",
    "spec/plist4r/commands_spec.rb",
    "spec/plist4r/config_spec.rb",
    "spec/plist4r/mixin/array_dict_spec.rb",
    "spec/plist4r/mixin/data_methods_spec.rb",
    "spec/plist4r/mixin/haml4r/examples.rb",
    "spec/plist4r/mixin/ruby_stdlib_spec.rb",
    "spec/plist4r/plist_cache_spec.rb",
    "spec/plist4r/plist_spec.rb",
    "spec/plist4r/plist_type_spec.rb",
    "spec/plist4r_spec.rb",
    "spec/scratchpad.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<libxml-ruby>, [">= 0"])
      s.add_runtime_dependency(%q<haml>, [">= 0"])
      s.add_runtime_dependency(%q<libxml4r>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
    else
      s.add_dependency(%q<libxml-ruby>, [">= 0"])
      s.add_dependency(%q<haml>, [">= 0"])
      s.add_dependency(%q<libxml4r>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
    end
  else
    s.add_dependency(%q<libxml-ruby>, [">= 0"])
    s.add_dependency(%q<haml>, [">= 0"])
    s.add_dependency(%q<libxml4r>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
  end
end

