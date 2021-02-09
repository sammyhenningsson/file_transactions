# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

module FileTransactions
  # This command supports making changes to files.
  # The block passed to +::new+ must either return a +String+, in which case
  # the file content will be replace with that string.
  # Or the block must itself modify the file with desired changes (and return anything but a String).
  #
  # When this command has been executed, the file can be restored to the
  # previous state again by calling #undo.
  #
  # ==== Examples
  #
  #  # Pass in the filename  name to ::new
  #  cmd1 = ChangeFileCommand.new('some_existing_file') do
  #    <<~EOF
  #      Some content to that should
  #      replace the current file content.
  #    EOF
  #  end
  #
  #  # Files can also be modified manually.
  #  # Note: the block gets name as argument.
  #  cmd2 = ChangeFileCommand.new('another_existing_file') do |name|
  #    File.open(name, 'a') do |f|
  #      f.write("Add some more stuff at the end\n")
  #    end
  #  end
  class ChangeFileCommand < BaseCommand
    attr_reader :name, :block

    # @param name [String] The name of the file to be changed. May be just a name or an absolut or relative path
    def initialize(name, &block)
      @name = name
      @block = block
    end

    private

    def before
      CreateFileCommand.execute(tmp_name) do
        FileUtils.copy name, tmp_name
      end
    end

    def execute!
      value = block.call(name)
      return unless value.is_a? String

      File.open(name, 'w') { |f| f.write(value) }
    end

    def undo!
      FileUtils.copy(tmp_name, name) if File.exist? tmp_name
    end

    def tmp_name
      @tmp_name ||= File.join(Dir.mktmpdir, File.basename(name))
    end
  end
end
