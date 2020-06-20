# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

module FileTransactions
  # This command supports deleting a file.
  #
  # When this command has been executed, the file can be restored by calling
  # #undo
  #
  # ==== Examples
  #
  #  # Pass in the filename  name to ::new
  #  cmd1 = DeleteFileCommand.new('some_existing_file')
  class DeleteFileCommand < BaseCommand
    attr_reader :name, :block

    # @param name [String] The name of the file to be deleted. May be just a name or an absolut or relative path
    def initialize(name)
      @name = name
    end

    private

    def before
      CreateFileCommand.execute(tmp_name) do
        FileUtils.copy name, tmp_name
      end
    end

    def execute!
      File.delete name
    end

    def undo!
      FileUtils.copy tmp_name, name
    end

    def tmp_name
      @tmp_name ||= File.join(Dir.mktmpdir, File.basename(name))
    end
  end
end
