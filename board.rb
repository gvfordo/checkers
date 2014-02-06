require_relative './piece.rb'

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
  
  def initialize(add_pieces = true)
    set_up_grid
    create_pieces if add_pieces
  end
  
  def [](x, y)
    @board[y][x]
  end
  
  def []=(x, y, piece)
    @board[y][x] = piece
  end
  
  def move_piece(starting, color, moves)
    x, y = starting
    raise InvalidMoveError if self[x, y].nil?
    raise InvalidMoveError unless self[x, y].color == color
    raise InvalidMoveError unless valid_move_seq?(starting, moves)
    perform_moves!(starting, moves)
  end
  
  # private
  def perform_slide(starting, ending)
    return false unless legal_move?(starting, ending)
    
    move!(starting, ending)
    maybe_promote(ending)
    
    true
  end

  # private
  def perform_jump(starting, ending)
    return false unless legal_move?(starting, ending, true)
    
    capture_piece(starting, ending)
    move!(starting, ending)
    maybe_promote(ending)
    
    true
  end
  
  # private
  def legal_move?(start, ending, jump = false)
    # check if starting pos is on board - create on_board?(pos) method
    return false if ending.any?{ |num| !num.between?(0, 7)}
    return false if ending.reduce(&:+).even? # put in method - playable_square?
    return false unless self[ending[0], ending[1]].nil? 
    
    move_vectors(start, jump).any? do |vector| 
      apply_vector(start, vector) == ending 
    end
  end
  
  # private
  def valid_move_seq?(starting, moves)
    new_board = self.dup
    new_board.perform_moves!(starting, moves)
  end
  
  def perform_moves!(starting, moves)
    if moves.count == 1
      return perform_slide(starting, moves[0]) || perform_jump(starting, moves[0])
    end

    moves.each do |ending|
      return false unless perform_jump(starting, ending)
      starting = ending
    end
    
    true
  end
  
  def dup
    new_board = Board.new(false)
    
    pieces.each do |piece|
      piece = piece.dup_with_board(new_board)
      x, y = piece.pos
      new_board[x, y] = piece
      # new_board[x, y] = Piece.new([x, y], new_board, piece.color, piece.king)
    end
  
    new_board
  end
  
  def game_over?
    pieces_for(:red).empty? || pieces_for(:black).empty?
  end
  
  def winner
    return :black if pieces_for(:red).empty?
    return :red if pieces_for(:black).empty?
    nil
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
  
  def pieces_for(color)
    pieces.select{ |piece| piece.color == color }
  end
  
  def pieces
    @board.flatten.compact
  end
  
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
  
    raise InvalidMoveError if self[j_x, j_y].nil?
    raise InvalidMoveError if self[j_x, j_y].color == self[start_x, start_y].color
    self[j_x, j_y] = nil
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
  
  def set_up_grid
     @board = Array.new(8){ Array.new(8) }
  end
  
  def create_pieces
    6.times do |row|
      row = row + 2 if row > 2
      8.times do |col|
        color = (row > 2 ? :red : :black)
        next if (col + row).even?
        p @board
        @board[row][col] = Piece.new([col, row], self, color)
      end
    end
  end
end
