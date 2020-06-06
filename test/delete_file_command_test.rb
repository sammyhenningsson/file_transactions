# frozen_string_literal: true

require "test_helper"

module FileTransactions
  class DeleteFileCommandTest < Test
    def setup
      in_project do
        File.open('some_file', 'w') { |f| f.write('original content') }
      end
    end

    def test_that_it_can_delete_a_file_and_undo
      command = DeleteFileCommand.new('some_file')

      in_project do
        command.execute

        refute File.exist? 'some_file'

        command.undo

        assert File.exist? 'some_file'
        assert File.read('some_file') == 'original content'
      end
    end
  end
end
