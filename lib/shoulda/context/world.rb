module Shoulda
  module Context
    class << self
      # @private
      def contexts
        @contexts ||= []
      end
      # @private
      attr_writer :contexts

      # @private
      def current_context
        self.contexts.last
      end

      # @private
      def add_context(context)
        self.contexts.push(context)
      end

      # @private
      def remove_context
        self.contexts.pop
      end
    end
  end
end
