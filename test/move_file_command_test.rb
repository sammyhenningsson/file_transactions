# frozen_string_literal: true

require "test_helper"

module FileTransactions
  class MoveFileCommandTest < Test
    def setup
      in_project do
        File.open('some_file', 'w') { |f| f.write('original content') }
      end
    end

    def test_that_it_can_move_a_file_and_undo
      command = MoveFileCommand.new(from: 'some_file', to: 'moved_file')

      in_project do
        command.execute

        refute File.exist? 'some_file'
        assert File.exist? 'moved_file'

        command.undo

        assert File.exist? 'some_file'
        assert File.read('some_file') == 'original content'
        refute File.exist? 'moved_file'
      end
    end

    def test_that_it_can_move_into_a_new_directory
      command = MoveFileCommand.new(from: 'some_file', to: 'new_dir1/new_dir2/moved_file')

      in_project do
        command.execute

        refute File.exist? 'some_file'
        assert File.exist? 'new_dir1/new_dir2/moved_file'

        command.undo

        assert File.exist? 'some_file'
        assert File.read('some_file') == 'original content'
        refute Dir.exist? 'new_dir1'
      end
    end
  end
end
