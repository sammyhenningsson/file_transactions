# frozen_string_literal: true

require 'fileutils'

module FileTransactions
  # This command creates a new directory. It will also create parent
  # directories if the given path contains directories that doesn't exist.
  #
  # When this command has been executed, the created directories can be removed
  # again by calling #undo.
  #
  # ==== Examples
  #
  #  # Pass in the new directory name to ::new
  #  cmd1 = CreateDirectoryCommand.new('directory_name')
  #
  #  # The new directory name may be a path of multiple non exsting directories (like `mkdir -p`)
  #  cmd2 = CreateDirectoryCommand.new('non_existing_dir1/non_existing_dir2/new_dir')
  class CreateDirectoryCommand < BaseCommand
    attr_reader :name

    # @param name [String] The name of the new directory. May be just a name or an absolut or relative path
    def initialize(name)
      @name = name
    end

    private

    def execute!
      dir = name

      until Dir.exist? dir
        directories.unshift dir
        dir = File.dirname dir
      end

      directories.each { |dir| Dir.mkdir dir }
    end

    def undo!
      directories.reverse_each { |dir| Dir.unlink dir }
    end

    def directories
      @directories ||= []
    end
  end
end
