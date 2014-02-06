require 'colorize'
require_relative './board'
require_relative './errors'

class Game
  attr_reader :board
  def initialize
    @board = Board.new
    @turn = :red
  end  
  
  def show_board
    system('clear')
    puts @board
  end
  
  def play 
    until game_over?
      show_board
      puts "It is #{@turn}'s turn"
      begin
        start, moves = get_input_from_player
        @board.move_piece(start, @turn, moves)
      rescue InvalidMoveError, TypeError => e
        puts e.message
        retry
      end   
      switch_turn
    end
    
    puts "Congratulations #{winner} you've won the game!"
  end
  
  private
  
  def winner
    @board.winner.to_s
  end
  
  def game_over?
    @board.game_over?
  end
  
  def get_input_from_player
    puts "Enter a start square, and a move or move sequence.  eg. 1,0 0,1"
    sequence = gets.chomp.split(" ")
    starting = sequence.first.split(",").map(&:to_i)
    remaining = sequence.drop(1).map{|move| move.split(",").map(&:to_i) }
    [starting, remaining]
  end
  
  def switch_turn
    @turn = (@turn == :red ? :black : :red)
  end
end


game = Game.new
game.play
 