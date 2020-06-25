# FileTransactions

This gem makes it easy to wrap code in classes using the command pattern. This means that a specific operation/task can be executed and after that, it can be undone. Multiple commands can be grouped in a (non-database) transaction, that will undo all executed commands if an exception is raised.
This gem includes a few commands for simple file operations.

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

FileTransactions provides a few basic commands for file operations:
 - `CreateFileCommand`
 - `CreateDirectoryCommand`
 - `ChangeFileCommand`
 - `DeleteFileCommand`
 - `MoveFileCommand`

All commands inherit from `FileTransactions::BaseCommand`, which requires subclasses to implement `#execute!`, `#undo!` and `#initialize`
They may also implement `#before` and `#after` which will be executed before or after `#execute` gets called.
If the `#before` or `#after` methods includes any commands, those sub commands will be undone when the command gets undone.
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

If the block passed to `CreateFileCommand.new` returns a `String` then the file will be created with that string as the file content.
If you rather create the file yourself (for example to set some specific file permissions etc), then simply return anything but a `String` instance.
Just make sure to create a file with the same name (Note: the filename also gets passed to the block). So instead we can do:
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

Commands are not limited to file operations and can be used for anything with side effects. By inheriting `FileTransactions::BaseCommand` commands get the required methods to be executed, undone and registered withing other commands and transactions. However you must yourself keep track of the side effects and what needs to be undone.

For example, say that you use an api for managing tasks, then some simple commands like this could be used:
```ruby
require 'file_transactions'

class ClaimTask < FileTransactions::BaseCommand
  attr_reader :task

  def initialize(task)
    @task = task
  end

  private

  def execute!
    response = task.post('claim-task')
    raise unless (200..299).cover? response.http_status
  end

  def undo!
    response = task.delete('assignee')
    raise unless (200..299).cover? response.http_status
  end
end

class UpdateTaskEstimate < FileTransactions::BaseCommand
  attr_reader :task, :estimate

  def initialize(task, estimate)
    @task = task
    @estimate = estimate
  end

  private

  def execute!
    @previous_estimate = task.attribute(:estimated_time)
    update(estimate)
  end

  def undo!
    update(@previous_estimate)
  end

  def update(estimated_time)
    form = task.get(:edit_form)
    form[:estimated_time] = estimated_time
    task = form.submit
    raise unless (200..299).cover? task.http_status
  end
end
```
Then this commands can now be put together in a transaction, that ensure that a task is claimed and given an estimate. If an exception is raise then the transaction will be rolled back and the task will be unassigned again.
```ruby
tasks = ShafClient.new('https://some-task-api.com/', user: 'john', password: 'doe')
                  .get_root
                  .get(:unassigned_tasks)

task = select_suitable_task(tasks)

FT.transaction do
  ClaimTask.execute(task)
  estimated_time = rand(1..5) * 8
  raise 'Too much work' if estimated_time > 30
  UpdateTaskEstimate.execute(task, estimated_time)
end
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sammyhenningsson/file_transactions.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
