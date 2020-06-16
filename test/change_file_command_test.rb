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

        assert_file_exist @filename
        assert_file_content @filename, 'new content'


        command.undo

        assert_file_exist @filename
        assert_file_content @filename, @original_content
        assert_clean_project
      end
    end

    def test_that_it_change_a_file_with_content_from_block
      command = ChangeFileCommand.new(@filename) { 'new content' }

      in_project do
        command.execute

        assert_file_exist @filename
        assert_file_content @filename, 'new content'


        command.undo

        assert_file_exist @filename
        assert_file_content @filename, @original_content
        assert_clean_project
      end
    end

    def test_that_it_passes_the_filename_to_the_block
      command = ChangeFileCommand.new(@filename) { |name| "changed: #{name}" }

      in_project do
        command.execute

        assert_file_content 'file', "changed: #{@filename}"
      end
    end
  end
end
