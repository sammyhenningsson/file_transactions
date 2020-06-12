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
      CreateDirectoryCommand.execute(File.dirname(to))
    end

    def execute!
      File.rename from, to
    end

    def undo!
      File.rename to, from
    end
  end
end
