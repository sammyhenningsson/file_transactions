# frozen_string_literal: true

module FileTransactions
  class BaseCommand
    def add_before(task)
      before_tasks << task
    end

    def add_after(task)
      after_tasks << task
    end

    def execute
      before
      before_tasks.map(&:execute)
      execute!
      after
      after_tasks.map(&:execute)
    rescue StandardError => e
      # FIXME
      puts e
    end

    def undo
      after_tasks.reverse_each.map(&:undo)
      undo!
      before_tasks.reverse_each.map(&:undo)
    rescue StandardError => e
      # FIXME
      puts e
    end

    private

    def before; end

    def execute!
      raise NotImplementedError, "#{self.clas} must implement #execute"
    end

    def undo!
      raise NotImplementedError, "#{self.clas} must implement #undo"
    end

    def after; end

    def before_tasks
      @before_tasks ||= []
    end

    def after_tasks
      @after_tasks ||= []
    end
  end
end

FT = FileTransactions
