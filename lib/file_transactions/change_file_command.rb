# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

module FileTransactions
  class ChangeFileCommand < BaseCommand
    attr_reader :name, :block

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
      FileUtils.copy tmp_name, name
    end

    def tmp_name
      @tmp_name ||= File.join(Dir.mktmpdir, File.basename(name))
    end
  end
end
