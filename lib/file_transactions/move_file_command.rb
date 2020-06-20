# frozen_string_literal: true

module FileTransactions
  # This command supports moveing (renaming) a file. It will also create parent
  # directories if the given path contains directories that doesn't exist.
  #
  # When this command has been executed, the file can be moved back to the
  # original location again by calling #undo. Any directories created during
  # #execute will be deleted.
  #
  # ==== Examples
  #
  #  cmd1 = MoveFileCommand.new('some_existing_file', 'some_new_dir/a_new_name')
  class MoveFileCommand < BaseCommand
    attr_reader :from, :to

    # @param from [String] The name of the source file to be renamed. May be just a name or an absolut or relative path
    # @param to [String] The target name of the file. May be just a name or an absolut or relative path
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
