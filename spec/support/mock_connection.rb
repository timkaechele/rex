class MockConnection
  def initialize
    @inbox = []
  end

  def send(message)
    # @inbox.push(message)
  end

  def messages
    @inbox
  end

  def clear_inbox!
    @inbox = []
  end
end
