# FileTransactions

This gem ships with a few file commands that can be executed and undone. Multiple commands can be grouped in a transation, that will undo all executed commands if an exception is raised.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'file_transactions'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install file_transactions

## Usage

FileTransactions provides a few basic comamnds for file operations:
change_file_command.rb  create_directory_command.rb  create_file_command.rb  delete_file_command.rb  error.rb  move_file_command.rb
 - `CreateFileCommand`
 - `CreateDirectoryCommand`
 - `ChangeFileCommand`
 - `DeleteFileCommand`
 - `MoveFileCommand`

All commands inherit from `FileTransactions::BaseCommand`, which requires subclasses to implement `#execute!`, `#undo!` and `#initialize`
The may also implement `#before` and `#after` which will be executed before or after `#execute` gets called.
If `#before` or `#after` update includes any commands, those sub commands will be undone when the command gets undone.
Multiple commands can be grouped together in a transaction, which will make sure all commands will get executed or all of them will be undone if a rollback happens.

## Examples

Create a new file:
```ruby

  cmd = FileTransactions::CreateFileCommand.new('my_file') do
    "some content that will be written to this new file"
  end

  cmd.execute

  File.exist? 'my_file' # true

  cmd.undo

  File.exist? 'my_file' # false
```

If the block passed to `CreateFileCommand::new` returns a `String` then the file will be created with that string as the file content.
If you rather create the file yourself (for example to set some specific file permissions etc), then simply return anything but a `String` instance.
Just make short to create a file with the same name (Note: the filename also gets passed to the block). So instead we can do:
```ruby

  cmd = FileTransactions::CreateFileCommand.new('my_file') do |name|
    File.open(name, 'w') do |f|
      f.write 'some content that will be written to this new file'
    end
  end
```

There is also a short version to create and call a command at once:
```ruby

  cmd = FileTransactions::CreateFileCommand.execute('my_file') { 'some file content' }
```

Sometimes it may be useful to create an alias for `FileTransactions` to save some key strokes:
```ruby
# In an initializer file or somewhere just after requiring 'file_transactions'
FT = FileTransactions

# Then simply type
cmd = FT::CreateFileCommad.new('foo') { 'bar }
```

A transaction is simply a call to `FileTransactions.transaction` passing a block that contains commands:
```ruby
FT.transaction do
  CreateDirectoryCommand.execute('some_directory')
  MoveFileCommand.execute('some_file', 'some_directory/some_file')
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/file_transactions.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
