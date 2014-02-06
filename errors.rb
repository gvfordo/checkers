class InvalidMoveError < StandardError
  def initialize(msg = "That is not a legal move")
    super
  end
end

class TypeError
  def initialize(msg = "Work harder on your input!")
    @msg = "Work harder on your input!"
    super
  end
end
