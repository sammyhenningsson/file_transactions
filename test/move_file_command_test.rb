# frozen_string_literal: true

require "test_helper"

module FileTransactions
  class MoveFileCommandTest < Test
    def setup
      @filename = 'file'
      @original_content = in_project { File.read('file') }
    end

    def test_that_it_can_move_a_file_and_undo
      command = MoveFileCommand.new(from: @filename, to: 'moved_file')

      in_project do
        command.execute

        refute_file_exist @filename
        assert_file_exist 'moved_file'

        command.undo

        assert_file_exist @filename
        assert_file_content(@filename, @original_content)
        refute_file_exist 'moved_file'
        assert_clean_project
      end
    end

    def test_that_it_can_move_into_a_new_directory
      command = MoveFileCommand.new(from: @filename, to: 'new_dir1/new_dir2/moved_file')

      in_project do
        command.execute

        refute_file_exist @filename
        assert_file_exist 'new_dir1/new_dir2/moved_file'

        command.undo

        assert_file_exist @filename
        assert_file_content(@filename, @original_content)
        refute_dir_exist 'new_dir1'
        assert_clean_project
      end
    end
  end
end
