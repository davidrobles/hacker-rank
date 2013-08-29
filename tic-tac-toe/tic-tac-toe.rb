###################################
# David Robles <drobles@gmail.com #
###################################

class TicTacToe

  WINS = %w(000000111 000111000 111000000 001001001 010010010 100100100 100010001 001010100).map! {|x| x.to_i(2) }

  def initialize
    reset
  end

  def check_win(bitboard)
    WINS.any? { |win| win & bitboard == win }
  end

  def legal_moves
    return [] if win?
    legal = ~(@crosses | @noughts)
    9.times.find_all { |move| legal & (1 << move) > 0}
  end

  def num_empty_cells
    legal = ~(@crosses | @noughts)
    9.times.count { |move| legal & (1 << move) > 0 }
  end

  def bit_moves
    legal_moves.map { |move| (1 << move) }
  end

  def to_s
    str = "Legal moves: #{legal_moves_cool.inspect}\n"
    str += "Current player: #{cur_player}\n\n"
    9.times do |i|
      if @crosses & (1 << i) > 0
        str += ' X '
      elsif @noughts & (1 << i) > 0
        str += ' 0 '
      else
        str += ' - '
      end
      str += "\n" if i % 3 == 2
    end
    if is_over?
      str += "\nGame over!"
    end
    str + "\n"
  end

  def set_cur_board(board)
    if cur_player == 0
      @crosses = board
    else
      @noughts = board
    end
  end

  def cur_board
    cur_player == 0 ? @crosses : @noughts
  end

  def win?
    check_win(@crosses) or check_win(@noughts)
  end

  # Game
 
  def copy
    tic = TicTacToe.new
    tic.crosses = @crosses
    tic.noughts = @noughts
    tic
  end

  def cur_player
    (num_empty_cells + 1) % 2
  end

  def make_move(move)
    bit_ms = bit_moves
    raise 'Illegal move' if move < 0 or move >= bit_ms.length
    set_cur_board(cur_board | bit_ms[move])
  end

  def num_moves
    bit_moves.length
  end

  def is_over?
    num_moves == 0
  end

  def outcomes
    return [:na, :na] unless is_over?
    return [:win, :loss] if check_win(@crosses)
    return [:loss, :win] if check_win(@noughts)
    [:draw, :draw]
  end

  def legal_moves_cool
    legal_moves.map { |m| num_to_coord(m) }
  end

  def num_to_coord(num)
    [num / 3, num % 3]
  end

  def reset
    @crosses = @noughts = 0
  end

  attr_writer :crosses, :noughts

end

class TicTacToeUtility

  def initialize(options={})
    @win_value  = options[:win]  ||  1.0
    @loss_value = options[:loss] || -1.0
    @draw_value = options[:draw] ||  0.0
  end

  def value(game, player)
    if game.is_over?
      outcome = game.outcomes[player]
      case outcome
        when :win  then return @win_value
        when :loss then return @loss_value
        when :draw then return @draw_value
      end
      raise 'Outcome should be win, draw or loss.'
    end
    raise 'Game must be over to call the utility function.'
  end

end

class AlphaBetaPlayer

  def initialize(eval_func, util_func)
    @eval_func = eval_func
    @util_func = util_func
  end

  def alpha_beta(game, cur_depth, alpha, beta)
    if game.is_over?
      p = game.cur_player
      return -1, @util_func.value(game, p)
    end
    best_move = -1
    best_score = -1000000
    num_moves = game.num_moves
    num_moves.times do |move|
      new_game = game.copy
      new_game.make_move(move)
      _, recursed_score = alpha_beta(new_game, cur_depth + 1, -beta, -([alpha, best_score].max))
      cur_score = -recursed_score
      if cur_score > best_score
        best_move = move
        best_score = cur_score
        return [best_move, best_score] if best_score >= beta
      end
    end
    [best_move, best_score]
  end

  def move(game)
    move = alpha_beta(game, 0, -1000000, 1000000)
    move[0]
  end

  def to_s
    'Alpha-Beta'
  end

end

def convert_board(board)
  bo = { noughts: 0, crosses: 0 }
  board.each_with_index do |line, row|
    line.each_with_index do |cell, col|
      if cell == 'X'
        bo[:crosses] = (1 << ( ((row * 3) + col))) | bo[:crosses]
      elsif cell == 'O'
        bo[:noughts] = (1 << ( ((row * 3) + col))) | bo[:noughts]
      end
    end
  end
  bo
end

def next_move(player, board)
  tic = TicTacToe.new
  b = convert_board(board)
  tic.noughts = b[:noughts]
  tic.crosses = b[:crosses]
  ab = AlphaBetaPlayer.new(nil, TicTacToeUtility.new)
  move = ab.move(tic)
  cool = tic.legal_moves_cool[move]
  puts "#{cool[0]} #{cool[1]}"
end

