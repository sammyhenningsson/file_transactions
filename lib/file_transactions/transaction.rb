# frozen_string_literal: true

module FileTransactions
  class Transaction
    class << self
      def run(&block)
        new(&block).__send__(:run)
      end

      def current=(transaction)
        Thread.current['FT::Transaction'] = transaction
      end

      def current
        Thread.current['FT::Transaction']
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

    private

    attr_reader :block, :commands

    def run
      outer_transaction = Transaction.current
      Transaction.current = self
      block.call
    rescue StandardError
      rollback
      raise
    ensure
      Transaction.current = outer_transaction
    end

    def rollback
      commands.reverse_each(&:undo)
    end
  end
end
