require 'csv'
require 'minitest/test'
require 'minitest/autorun'
require 'minitest/emoji'
require_relative '../lib/event_reporter'

class EventReporterTest < Minitest::Test

  def setup
    @e = EventReporter.new
  end

  def test_load_method_loads_default_csv
    @e.run_program("load")

    assert_equal 5175, @e.open_file.length
  end

  def test_load_method_loads_any_csv
    @e.run_program("load test_file.csv")

    assert_equal 15, @e.open_file.length
  end

  def test_help_method_outputs_all_available_commands
    expected =
    "Here are a list of commands available to you:\n
    load <filename>\n
    help <command>\n
    queue count\n
    queue clear\n
    queue print\n
    queue print by <attribute>\n
    queue save to <filename.csv>\n
    find <attribute> <criteria>\n"

    assert_equal expected, @e.run_program("help")
  end

  def test_help_method_with_an_argument_passed_in_works
    expected = "Output how many records are in the current queue"

    assert_equal expected, @e.run_program("help queue count")
  end

  def test_queue_count_method_returns_the_proper_count
    @e.run_program("load")

    assert_equal 5175, @e.run_program("queue count")
  end

  def test_queue_clear_empties_the_queue
    @e.run_program("load")
    @e.run_program("queue clear")

    assert_equal 0, @e.open_file.length
  end

  def test_queue_print_has_correct_data
    @e.run_program("load tiny_test_file.csv")
    table = @e.run_program("queue print")

   assert_equal "Nguyen", table.rows[0].cells[1].value
   assert_equal "Saint Petersburg", table.rows[2].cells[5].value
  end

  def test_queue_print_by_has_sorts_table_correctly
    @e.run_program("load tiny_test_file.csv")
    table = @e.run_program("queue print by zipcode")

   assert_equal "20009", table.rows[0].cells[7].value
   assert_equal "20010", table.rows[1].cells[7].value
   assert_equal "33703", table.rows[2].cells[7].value
   assert_equal "37216", table.rows[3].cells[7].value

   table = @e.run_program("queue print by first_name")

   assert_equal "Allison", table.rows[0].cells[0].value
   assert_equal "Jennifer", table.rows[1].cells[0].value
  end

end
