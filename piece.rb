class Piece
  attr_accessor :pos, :king, :board
  attr_reader :color
  
  def initialize(pos, board, color, king = false)
    @pos, @board, @color, @king = pos, board, color, king
  end
  
  def to_s
    (king ? " \u260E " : " \u25C9 ").colorize(color)
  end
  
  def dup_with_board(board)
    new_piece = self.dup
    new_piece.board = board
    new_piece
  end
end