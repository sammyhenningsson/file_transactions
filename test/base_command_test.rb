# frozen_string_literal: true

require "test_helper"

module FileTransactions
  class BaseCommandTest < Test
    def log(value = nil)
      @log ||= []
      @log << value if value
      @log
    end

    def mock_command(name, log)
      Class.new(BaseCommand) do
        def initialize(name, log)
          @name = name
          @log = log
        end

        def execute!
          "exec #{@name}".tap { |str| @log.push str }
        end

        def undo!
          "undo #{@name}".tap { |str| @log.push str }
        end
      end.new(name, log)
    end

    def test_that_it_can_run
      cmd = mock_command('Foo', log)

      cmd.execute

      assert_equal ['exec Foo'], log
    end

    def test_that_it_can_be_undone
      cmd = mock_command('Foo', log)
      cmd.execute
      cmd.undo

      assert_equal ['exec Foo', 'undo Foo'], log
    end

    def test_that_it_runs_correct_values
      cmd = mock_command('Foo', log)

      assert_equal 'exec Foo', cmd.execute
      assert_equal 'undo Foo', cmd.undo
    end

    def test_that_it_can_not_be_undone_if_it_hasnt_run
      cmd = mock_command('Foo', log)

      error = assert_raises(FT::Error) do
        cmd.undo
      end

      assert_match(/Cannot undo.*which hasn't been executed/, error.message)
    end
  end
end
