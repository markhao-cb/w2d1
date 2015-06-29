require_relative 'board'
require_relative 'tile'

class Game
  attr_reader :board

  def initialize(size, num_bombs)
    @board = Board.new(size, num_bombs)
  end

  def play
    until over?
      board.render
      input = get_input
      make_move(input)
    end

    if self.board.won?
      board.reveal(true)
      puts "You won!"
    else
      board.reveal(false)
      puts "Game over!"
    end
    board.render
  end

  private

    def make_move(input)
      row, col = input[0]
      type = input[1]

      tile = self.board[row, col]
      if type == 'r'
        tile.reveal
      elsif type == 'f'
        tile.status = tile.status == :flagged ? :hidden : :flagged
      end
    end

    def over?
      self.board.grid.each_with_index do |row, row_index|
        row.each_with_index do |col, col_index|
          return true if self.board[row_index,col_index].status == :bombed
          return true if self.board.won?
        end
      end

      false
    end

    def get_input
      pos = get_input_pos
      type = get_input_type

      [pos, type]
    end

    def get_input_pos
      row, col = nil, nil

      until valid_position?([row,col])
        puts "Enter a row."
        row = gets.chomp.to_i
        puts "Enter a column."
        col = gets.chomp.to_i
      end

      [row, col]
    end

    def get_input_type
      type = nil

      until valid_move?(type)
        puts "Enter 'r' or 'f' to reveal or flag the position."
        type = gets.chomp.downcase
      end

      type
    end

    def valid_position?(input)
      input.each do |el|
        return false unless el.is_a?(Integer) && el.between?(0, 8)
      end
      !self.board[*input].revealed?
    end

    def valid_move?(input)
      input == 'r' || input == 'f'
    end
end

game = Game.new(9,10)
game.play
