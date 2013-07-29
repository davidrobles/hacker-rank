
n = 5
grid = ["-p-", "---", "--m"]

def nextMove(n,x,y,grid)
  pos = find_positions(grid)
  result = ""

  # offsets
  vert_diff = pos[:m][:row] - pos[:p][:row]
  hor_diff = pos[:m][:col] - pos[:p][:col]

  # vertical
  if vert_diff < 0
	puts "DOWN\n"
  elsif vert_diff > 0
    puts "UP\n"
  # horizontal
  elsif hor_diff < 0
	puts "RIGHT\n"
  elsif hor_diff > 0
	puts "LEFT\n"
  end
end

def find_positions(lines)
  hash = {}
  lines.each_with_index do |line, row|
    line.split('').each_with_index do |cell, col|
      if cell == 'p'
        hash[:p] = { row: row, col: col }
      elsif cell == 'm'
        hash[:m] = { row: row, col: col }
      end
    end
  end
  hash
end

puts displayPathtoPrincess(n, x, y, grid)

