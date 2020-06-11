# frozen_string_literal: true

require "test_helper"

module FileTransactions
  class DeleteFileCommandTest < Test
    def setup
      @filename = 'file'
      @original_content = in_project { File.read('file') }
    end

    def test_that_it_can_delete_a_file_and_undo
      command = DeleteFileCommand.new(@filename)

      in_project do
        command.execute

        refute File.exist? @filename

        command.undo

        assert File.exist? @filename
        assert File.read(@filename) == @original_content
        assert_clean_project
      end
    end
  end
end
