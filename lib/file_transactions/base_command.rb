# frozen_string_literal: true

module FileTransactions
  class BaseCommand
    class << self
      def execute(*args, &block)
        new(*args, &block).execute
      end

      def current=(command)
        Thread.current['FT::Command'] = command
      end

      def current
        Thread.current['FT::Command']
      end
    end

    def execute
      outer_command = BaseCommand.current
      prepare
      run_before
      run_excecute
      run_after
    rescue StandardError
      self.failure_state = state
      raise
    ensure
      BaseCommand.current = outer_command
    end

    def undo
      raise Error, "Cannot undo #{self.class} which hasn't been executed" unless executed?

      sub_commands[:after].reverse_each(&:undo)
      undo! unless failure_state == :before
      sub_commands[:before].reverse_each(&:undo)
    end

    def register(command)
      sub_commands[state] << command
    end

    def executed?
      !!executed
    end

    def failed?
      !!failure_state
    end

    private

    attr_accessor :state, :executed, :failure_state

    def prepare
      (BaseCommand.current || Transaction.current)&.register self

      BaseCommand.current = self
      self.executed = true
    end

    def sub_commands
      @sub_commands ||= {
        before: [],
        exec: [],
        after: [],
      }
    end

    def run_before
      self.state = :before
      before
    end

    def run_excecute
      self.state = :exec
      execute!
    end

    def run_after
      self.state = :after
      after
    end

    def before; end

    def execute!
      raise NotImplementedError, "#{self.clas} must implement #execute"
    end

    def undo!
      raise NotImplementedError, "#{self.clas} must implement #undo"
    end

    def after; end
  end
end
