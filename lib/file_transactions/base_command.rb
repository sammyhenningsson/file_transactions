# frozen_string_literal: true

module FileTransactions
  # A Base class that all commands must inherit from.
  #
  # This class provides all the necessary methods/hooks to make it possible to
  # group commands together and/or nested inside transactions (and other
  # commands).
  class BaseCommand
    def self.execute(*args, **kwargs, &block)
      if RUBY_VERSION < '3.0' && kwargs.empty?
        new(*args, &block).tap { |cmd| cmd.execute }
      else
        new(*args, **kwargs, &block).tap { |cmd| cmd.execute }
      end
    end

    # Execute the command. This will trigger the following methods:
    #  * #before
    #  * #execute!
    #  * #after
    def execute
      scope = Transaction.scope
      scope&.register self
      prepare
      run_before
      run_excecute.tap { run_after }
    rescue StandardError
      self.failure_state = state
      raise
    ensure
      Transaction.scope = scope
    end

    # Undo the changes made from a previous call to #execute. All previouly
    # executed commands will be undone in reverse order.
    def undo
      raise Error, "Cannot undo #{self.class} which hasn't been executed" unless executed?

      sub_commands[:after].reverse_each(&:undo)

      ret = undo! unless failure_state == :before
      sub_commands[:before].reverse_each(&:undo)
      ret
    end

    # This registers a nested command. This method is called whever a command
    # is executed and should not be called manually.
    def register(command)
      sub_commands[state] << command
    end

    # Returns true of false depending on if the commands has been executed.
    def executed?
      !!executed
    end

    # Returns true if the command has been unsuccessfully executed, otherwise false.
    def failed?
      !!failure_state
    end

    private

    attr_accessor :state, :executed, :failure_state

    def prepare
      Transaction.scope = self
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
