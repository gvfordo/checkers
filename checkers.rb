require 'colorize'

class Fixnum
  def double
    self * 2
  end
end

class Board
  
  VECTORS = {
    :king => [[-1, -1],[-1, 1],[1, -1],[1, 1]],
    :red => [[-1, -1],[1, -1]],
    :black => [[-1, 1], [1, 1]]
  }
  
  def initialize(create_pieces = true)
    set_up_grid
    set_up_pieces if create_pieces
  end
  
  def [](x, y)
    @board[y][x]
  end
  
  def []=(x, y, piece)
    @board[y][x] = piece
  end
  
  def perform_slide(starting, ending)
    raise "That is not a legal slide" unless legal_move?(starting, ending)
    
    move!(starting, ending)
    maybe_promote(ending)
  end

  def perform_jump(starting, ending)
    raise "That is not a legal jump" unless legal_move?(starting, ending, true)
    
    capture_piece(starting, ending)
    move!(starting, ending)
    maybe_promote(ending)
  end
  
  def legal_move?(start, ending, jump = false)
    return false if ending.any?{ |num| !num.between?(0, 7)}
    return false if ending.reduce(&:+).even?
    return false unless self[ending[0], ending[1]].nil? 
    
    move_vectors(start, jump).any? do |vector| 
      apply_vector(start, vector) == ending 
    end
  end
  
  def perform_moves!(moves)
    
    
  
  end
  
  def to_s
    str = " "
    9.times { |num| next if num == 0; str << "  #{num - 1}"}
    str << "\n"
    @board.each_with_index do |row, idx|
      color = (idx % 2 == 0 ? false : true )
      str << "#{idx} "
      row.each do |square|
        str << (square.nil? ? "   " : square.to_s)
        .colorize(:background => (color ? :white :  :black))
        color = !color
      end
      str << "\n"
    end
    str
  end
  
  private
  
  def maybe_promote(ending)
    x, y = ending
    return if self[x, y].king
    
    promotion_row = (self[x, y].color == :red ? 0 : 7)
    self[x, y].king = true if y == promotion_row
  end
  
  def move!(starting, ending)
    start_x, start_y = starting
    end_x, end_y = ending
    
    piece = self[start_x, start_y]
    self[start_x, start_y] = nil
    piece.pos = [end_x, end_y]
    self[end_x, end_y] = piece
  end
  
  def capture_piece(starting, ending)
    start_x, start_y = starting
    end_x, end_y = ending
  
    #Find jumped square coordinates
    j_x = (start_x + end_x) / 2
    j_y = (start_y + end_y) / 2
  
    raise "no enemy there" unless  self[j_x, j_y] != nil
    raise "can't take your own piece" if self[j_x, j_y].color == self[start_x, start_y].color
    self[jumped_x, jumped_y] = nil
  end
  
  def move_vectors(starting, jump)
    x, y = starting
    color = self[x, y].color
    vectors = (self[x, y].king ? VECTORS[:king] : VECTORS[color])
    jump ? vectors.map{|vector| vector.map(&:double)} : vectors
  end
  
  def apply_vector(starting, vector)
    starting.zip(vector).map!{ |delta| delta.reduce(&:+) }
  end
  
  def set_up_red_pieces
    
  end
  
  def set_up_black_pieces
    
  end
  
  def set_up_grid
     @board = Array.new(8){ Array.new(8) }
  end
  
  def set_up_pieces
   
    # setup pieces
  end
end


class Piece
  attr_accessor :pos, :king
  attr_reader :color
  
  def initialize(pos, board, color, king = false)
    @pos = pos
    @board = board
    @color = color
    @king = king
  end
  
  def to_s
    (king ? " \u260E " : " \u25C9 ").colorize(color)
  end
  
end


class Game
  attr_reader :board
  def initialize
    @board = Board.new(false)
  end  
  
  def show_board
    # system('clear')
    puts @board
    puts "\n\n"
  end
  
  
end


game = Game.new

game.board[0, 1] = Piece.new([0, 1], self, :red)
#game.board[1, 2] = Piece.new([1, 2], self, :black )
#game.board[3, 2] = Piece.new([3, 2], self, :red )


 game.show_board
 game.board.perform_slide([0,1], [1, 0])
 game.show_board
 # game.board.perform_jump([0,1], [2, 3])
 # game.show_board
 # game.board.perform_jump([2,3], [4, 1])
 # game.show_board

 