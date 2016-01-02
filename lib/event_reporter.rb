require 'csv'
require 'terminal-table'
require 'reputs'
require 'pry'

#issues to look at: cleaning data, case sensitivity, table print out?

class EventReporter

  attr_reader :open_file, :prepped, :current_queue

  def initialize
    @open_file = []
    @current_queue = []
  end

  def load_file(filename = nil)
    if filename.nil?
      file = CSV.open("lib/event_attendees.csv", headers: true, header_converters: :symbol)
      @open_file = file.to_a
    else
      file = CSV.open("lib/#{filename}", headers: true, header_converters: :symbol)
      @open_file = file.to_a
    end
    reputs "File loaded!"
  end

  def help(parsed_command)
    if parsed_command.length == 1
      individual_commands
    else
      help_descriptions(parsed_command)
    end
  end

  def individual_commands
    reputs "Here are a list of commands available to you:\n
    load <filename>\n
    help <command>\n
    queue count\n
    queue clear\n
    queue print\n
    queue print by <attribute>\n
    queue save to <filename.csv>\n
    find <attribute> <criteria>\n"
  end

  def help_descriptions(parsed_command)
    query = parsed_command[1..-1].join(" ")
    case query
    when "queue count"
      reputs "Output how many records are in the current queue"
    when "queue clear"
      reputs "Empty the queue"
    when "queue print"
      reputs "Print out a tab-delimited data table"
    when query[0..2] == "queue print by"
      reputs "Print data table sorted by <attribute>"
    when query[0..2] == "queue save to"
      reputs "Export current queue to <filename> as a CSV"
    when query[0] == "find"
      reputs "Load the queue with all records matching <criteria> for <attribute>"
    end
  end

  def queue(parsed_command)
    if parsed_command[1..2] == ["print", "by"]
      print_by(parsed_command)
    elsif parsed_command[1..2] == ["save", "to"]
      save_to(parsed_command)
    else
      query = parsed_command[1..-1].join(" ")
      case query
      when "count"
        reputs @current_queue.length
      when "clear"
        @current_queue = []
      when "print"
        @prepped = prep_csv_rows
        reputs ascii_table
      end
    end
  end

  def prep_csv_rows
    hashes = @current_queue.map { |row| row.to_h }
    hashes.map { |row| row.values[2..-1]}
  end

  def sort_data(key)
    hashes = @current_queue.map { |row| row.to_h }
    hashes = hashes.sort_by { |h| h[key] }
    hashes.map { |row| row.values[2..-1]}
  end

  def print_by(parsed_command)
    key = parsed_command.last.to_sym
    @prepped = sort_data(key)
    reputs ascii_table
  end

  def ascii_table
    Terminal::Table.new :headings => ['First Name', 'Last Name', 'Email',
    'Phone', 'Address', 'City', 'State', 'Zipcode'], :rows => @prepped
  end

  def save_to(parsed_command)
    filename = parsed_command[3]
    prepped_data = @current_queue.map { |row| row.values[2..-1]}
    CSV.open(filename, "w") do |csv|
      csv << headers
      prepped_data.each do |row|
        csv << row
      end
    end
    reputs "File written!"
  end

  def find(parsed_command)
    attribute = parsed_command[1]
    criteria = parsed_command[2]
    hashes = @open_file.map { |row| row.to_h }
    hashes.each do |hash|
      if hash.has_value?(criteria) #attribute?
        @current_queue << hash
      end
    end
    reputs "#{current_queue.length} matching record(s) found"
  end

  def headers
    ["FIRST_NAME","LAST_NAME","EMAIL","PHONE","ADDRESS","CITY","STATE","ZIPCODE"]
  end

  def run_program(command)
    parsed_command = command.split(" ")
    case parsed_command[0]
    when "load"
      load_file(parsed_command[1])
    when "help"
      help(parsed_command)
    when "queue"
      queue(parsed_command)
    when "find"
      find(parsed_command)
    end
  end

end

if __FILE__ == $0
  e = EventReporter.new
  puts "*=*=*=*=*=*=*=*=*=*=*=*=*=*"
  puts "Welcome to Event Reporter!!"
  puts "*=*=*=*=*=*=*=*=*=*=*=*=*=*"
  loop do
    command = gets.chomp
    e.run_program(command)
  end
end
