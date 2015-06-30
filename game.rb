require_relative 'board'

class Game
  attr_reader :board

  def initialize(size, num_bombs)
    @board = Board.new(size, num_bombs)
  end

  def play
    until board.over?
      
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

  # Reads keypresses from the user including 2 and 3 escape character sequences.
  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  # oringal case statement from:
  # http://www.alecjacobson.com/weblog/?p=75
  def show_single_key
    system("clear")
    board.render

    c = read_char

    case c
    when "\e[A"
      # puts "UP ARROW"
      board.selected_pos[0] -= 1 unless board.selected_pos[0] < 1
    when "\e[B"
      board.selected_pos[0] += 1 unless board.selected_pos[0] > 7
      # puts "DOWN ARROW"
    when "\e[C"
      board.selected_pos[1] += 1 unless board.selected_pos[1] > 7
      # puts "RIGHT ARROW"
    when "\e[D"
      board.selected_pos[1] -= 1 unless board.selected_pos[1] < 1
      # puts "LEFT ARROW"
    when "r"
      make_move(board.selected_pos,"r")
    when "f"
      make_move(board.selected_pos,"f")
    when "s"
      save?
    end
  end
end
