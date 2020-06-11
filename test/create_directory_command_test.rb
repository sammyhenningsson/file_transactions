# frozen_string_literal: true

require "test_helper"

module FileTransactions
  class CreateDirectoryCommandTest < Test
    def test_that_it_creates_a_directory
      command = CreateDirectoryCommand.new('new_directory')

      in_project do
        command.execute

        assert_dir_exist 'new_directory'

        command.undo

        refute_dir_exist 'new_directory'
        assert_clean_project
      end
    end

    def test_that_it_creates_nested_directories
      command = CreateDirectoryCommand.new('dir1/dir2/dir3')

      in_project do
        command.execute

        assert_dir_exist 'dir1'
        assert_dir_exist 'dir1/dir2'
        assert_dir_exist 'dir1/dir2/dir3'

        command.undo

        refute_dir_exist 'dir1'
        assert_clean_project
      end
    end
  end
end
