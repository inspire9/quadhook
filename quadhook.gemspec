# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "quadhook"
  spec.version       = '0.0.1'
  spec.authors       = ["Pat Allan"]
  spec.email         = ["pat@freelancing-gods.com"]

  spec.summary       = %q{Webhook handler for Quaderno}
  spec.description   = %q{Rack endpoint for capturing webhook requests from Quaderno's invoicing service.}
  spec.homepage      = "https://github.com/inspire9/quadhook"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
