# frozen_string_literal: true

module FileTransactions
  class Transaction
    class << self
      def run(&block)
        new(&block).__send__(:run)
      end

      def scope=(scope)
        Thread.current['FT.scope'] = scope
      end

      def scope
        Thread.current['FT.scope']
      end

    end

    def initialize(&block)
      raise Error, 'A block must be given' unless block_given?

      @block = block
      @commands = []
    end

    def register(command)
      commands << command
    end

    def rollback
      return if backrolled?

      commands.reverse_each(&:undo)
      self.backrolled = true
    end
    alias undo rollback

    def backrolled?
      !!backrolled
    end

    private

    attr_reader :block, :commands
    attr_accessor :backrolled

    def run
      scope = Transaction.scope
      scope&.register self
      Transaction.scope = self
      block.call
    rescue StandardError => e
      rollback
      raise unless Rollback === e
    ensure
      Transaction.scope = scope
    end
  end
end
