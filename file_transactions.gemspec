require_relative 'lib/file_transactions/version'

Gem::Specification.new do |spec|
  spec.name          = 'file_transactions'
  spec.version       = FileTransactions::VERSION
  spec.authors       = ['Sammy Henningsson']
  spec.email         = ['sammy.henningsson@gmail.com']

  spec.summary       = 'Transactions for file operations'
  spec.description   = <<~DESC
                            A set of file operation that can be undone or wrapped in a
                            transaction. If the transaction is rolled back then all file
                            operations will be undone.
                          DESC
  spec.homepage      = 'https://github.com/sammyhenningsson/file_transactions'
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 2.5'

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files         = Dir['lib/**/*rb']
  spec.require_paths = ["lib"]
end
