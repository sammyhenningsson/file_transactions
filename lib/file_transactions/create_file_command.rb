# frozen_string_literal: true

module FileTransactions
  class CreateFileCommand < BaseCommand
    attr_reader :name, :block

    def initialize(name, &block)
      @name = name
      @block = block
    end

    def before
      dir = File.dirname(name)
      add_before CreateDirectoryCommand.new(dir)
    end

    def execute!
      value = block.call
      return unless value.is_a? String

      File.open(name, 'w') { |f| f.write(value) }
    end

    def undo!
      File.unlink name
    end
  end
end
