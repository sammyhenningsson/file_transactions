# frozen_string_literal: true

module FileTransactions
  # This command creates a new file. It will also create parent
  # directories if the given path contains directories that doesn't exist.
  # The block passed to +::new+ must either return a +String+ with the content
  # that will be written to the new file. Or the block must itself create the file
  # with the filname +name+ (and return anything but a String).
  #
  # When this command has been executed, the created file (and any directories)
  # can be removed again by calling #undo.
  #
  # ==== Examples
  #
  #  # Pass in the new directory name to ::new
  #  cmd1 = CreateFileCommand.new('new_name') do
  #    <<~EOF
  #      Some content to be
  #      written to the file.
  #    EOF
  #  end
  #
  #  # Files can also be created manually.
  #  # Note: the block gets name as argument.
  #  cmd2 = CreateFileCommand.new('another_file') do |name|
  #    GenerateAwesomeReport.call(filename: name)
  #    true
  #  end
  class CreateFileCommand < BaseCommand
    attr_reader :name, :block

    # @param name [String] The name of the new directory. May be just a name or an absolut or relative path
    def initialize(name, &block)
      @name = name
      @block = block
    end

    private

    def before
      dir = File.dirname(name)
      return if Dir.exist? dir
      CreateDirectoryCommand.execute(dir)
    end

    def execute!
      value = block.call(name)
      return unless value.is_a? String

      File.open(name, 'w') { |f| f.write(value) }
    end

    def undo!
      File.unlink(name) if File.exist? name
    end
  end
end
