# frozen_string_literal: true

require 'fileutils'

module FileTransactions
  class CreateDirectoryCommand < BaseCommand
    attr_reader :name

    # Create new command for creating directories. N
    #
    # ==== Attributes
    #
    # * +name+ - The name of the directory to be created
    #
    # ==== Examples
    #
    #  # Pass in the new directory name to ::new
    #  cmd1 = CreateDirectoryCommand.new('directory_name')
    #
    #  # The new directory may be a path of multiple non exsting directories (like `mkdir -p`)
    #  cmd2 = CreateDirectoryCommand.new('non_existing_dir1/non_existing_dir2/new_dir')
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
