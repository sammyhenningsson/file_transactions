# frozen_string_literal: true

module FileTransactions
  class MoveFileCommand < BaseCommand
    attr_reader :from, :to

    def initialize(from:, to:)
      @from = from
      @to = to
    end

    private

    def before
      dir_command = CreateDirectoryCommand.new(File.dirname(to))
      add_before dir_command
    end

    def execute!
      File.rename from, to
    end

    def undo!
      File.rename to, from
    end
  end
end
