require_relative 'lib/file_transactions/version'

Gem::Specification.new do |spec|
  spec.name          = 'file_transactions'
  spec.version       = FileTransactions::VERSION
  spec.authors       = ['Sammy Henningsson']
  spec.email         = ['sammy.henningsson@gmail.com']

  spec.summary       = 'Transactions for file operations'
  spec.description   = <<~DESC
                            A library for creating commands can be done and
                            undone. Multiple commands can be grouped together
                            in a transaction making sure all commands succeed
                            or gets rolled back. This gem includes a few
                            commands for file operations but it makes it easy
                            to create custom commands and use them for more
                            than just file operations.
                          DESC
  spec.homepage      = 'https://github.com/sammyhenningsson/file_transactions'
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 2.5'

  spec.metadata["homepage_uri"] = spec.homepage

  spec.cert_chain  = ['certs/sammyhenningsson.pem']
  spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem')

  spec.files         = Dir['lib/**/*rb']
  spec.require_paths = ["lib"]
end
