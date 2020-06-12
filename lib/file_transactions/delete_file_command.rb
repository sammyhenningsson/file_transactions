# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

module FileTransactions
  class DeleteFileCommand < BaseCommand
    attr_reader :name, :block

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
