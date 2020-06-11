# frozen_string_literal: true

require "test_helper"

module FileTransactions
  class ChangeFileCommandTest < Test
    def setup
      @filename = 'file'
      @original_content = in_project { File.read('file') }
    end

    def test_that_it_can_change_a_file_and_undo_it
      command = ChangeFileCommand.new(@filename) do
        File.open(@filename, 'w') { |f| f.write('new content') }
      end

      in_project do
        command.execute

        assert File.exist? @filename
        assert File.read(@filename) == 'new content'


        command.undo

        assert File.exist? @filename
        assert File.read(@filename) == @original_content
        assert_clean_project
      end
    end

    def test_that_it_change_a_file_with_content_from_block
      command = ChangeFileCommand.new(@filename) { 'new content' }

      in_project do
        command.execute

        assert File.exist? @filename
        assert File.read(@filename) == 'new content'


        command.undo

        assert File.exist? @filename
        assert File.read(@filename) == @original_content
        assert_clean_project
      end
    end
  end
end
