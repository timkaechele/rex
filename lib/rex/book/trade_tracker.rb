module Rex
  module Book
    class TradeTracker
      TRADE_HISTORY_LIMIT = 200
      def initialize
        @trades = []
      end

      def add(trade)
        @trades.push(trade)
        cap()
      end

      def fetch_trades(limit)
        @trades.last(limit)
      end

      private

      def cap()
        @trades = @trades.last(TRADE_HISTORY_LIMIT)
      end
    end
  end
end
