require_relative 'board'
require_relative 'tile'

class Game
  attr_reader :board

  def initialize(size, num_bombs)
    @board = Board.new(size, num_bombs)
  end

  def play
    until board.over?
      board.render
      if save?
        return
      end
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

  def save?
    answer = nil
    until valid_save_input?(answer)
      puts "Save and quit? (y/n)"
      answer = gets.chomp.downcase
    end

    if answer == 'n'
      return false
    else
      puts "What's the filename?"
      file_name = gets.chomp.downcase
      data = self.to_yaml
      File.open("#{file_name}.yml", 'w') { |f| f.puts data }
      return true
    end
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

  def valid_save_input?(input)
    input == 'y' || input == 'n'
  end
end

def valid_input?(input)
  input == 'l' || input == 'n'
end

if __FILE__ == $PROGRAM_NAME
  answer = nil
  until valid_input?(answer)
    puts "New game or load game? (n / l)."
    answer = gets.chomp.downcase
    if answer == "n"
      game = Game.new(9,10)
    elsif answer == "l"
      puts "Please enter the filename: "
      filename = gets.chomp
      filename = "#{filename}.yml"
      data = File.read(filename)
      game = YAML.load(data)
    else
      puts "Invalid input."
    end
  end
  game.play
end
