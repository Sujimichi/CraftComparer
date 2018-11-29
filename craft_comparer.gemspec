# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "craft_comparer/version"

Gem::Specification.new do |spec|
  spec.name          = "craft_comparer"
  spec.version       = CraftComparer::VERSION
  spec.authors       = ["Katateochi "]
  spec.email         = ["katateochi@gmail.com"]

  spec.summary       = %q{A tool for testing the similarity between two KSP craft files}
  spec.homepage      = "https://github.com/Sujimichi/CraftComparer"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  #spec.bindir        = "lib"  
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard", "~> 2.0"
  spec.add_development_dependency "guard-rspec", "~> 4.0"  
  spec.add_development_dependency "ffi", ">= 1.9.24"
  spec.add_runtime_dependency "thor", "~> 0"
  
end
