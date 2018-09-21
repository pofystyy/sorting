require "minitest/autorun"

class Rtest < Minitest::Test
  def setup
    @cars = 100.times.inject([]) do |arr, i| arr.push(
      id: i,
      price: rand(1000..25000),
      color: [:red, :blue, :white, :yellow, :black][rand(5)]
    )
    end
    @handler = ItemsHandler.new(@cars)
end

  # TESTS

  def test_paginate
    paginated_cars = @handler.paginate(5)
    assert_equal 5, @handler.current_page
    #assert_equal 40, paginated_cars[0][:id]
  end

  def test_prev_page_number_calculation
    @handler.paginate(9)
    assert_equal 8, @handler.prev_page_number
    @handler.paginate(1)
    assert_equal 10, @handler.prev_page_number
    @handler.paginate(10)
    assert_equal 9, @handler.prev_page_number
  end

  def test_next_page_number_calculation
    @handler.paginate(9)
    assert_equal 10, @handler.next_page_number
    @handler.paginate(1)
    assert_equal 2, @handler.next_page_number
    @handler.paginate(10)
    assert_equal 1, @handler.next_page_number
  end

  def test_last_page_number_calculation
    assert_equal 10, @handler.last_page_number
  end

  def test_asc_sorting
    sorted_cars = @handler.sort(:price).items
    refute_nil sorted_cars.map { |h| h[:price] }
                          .reduce(25000) { |prev, curr| (prev >= curr) ? curr : break }
  end

  def test_desc_sorting
    sorted_cars = @handler.sort(:price, :desc).items
    refute_nil sorted_cars.map { |h| h[:price] }
                          .reduce(0) { |prev, curr| (prev <= curr) ? curr : break }
  end

  def test_filtering
    filtered_cars = @handler.filter(:color, :red).items
    refute_nil filtered_cars.each { |car| car[:color] == :red ? true : break }
  end

  def test_sorting_with_filtering
    cars = @handler.sort(:price).filter(:color, :black).items
    refute_nil cars.map { |h| h[:price] }
                   .reduce(25000) { |prev, curr| (prev >= curr) ? curr : break }
    refute_nil cars.each { |car| car[:color] == :black ? true : break }
  end

  def test_wrong_page_param
    assert_raises(ItemsHandler::PaginateParamError) { @handler.paginate(-1) }
    assert_raises(ItemsHandler::PaginateParamError) { @handler.paginate(0) }
  end

  def test_unlimited_page_request
    assert_raises(ItemsHandler::NoItemsError) { @handler.paginate(11) }
    assert_raises(ItemsHandler::NoItemsError) { @handler.paginate(1000) }
  end

  def test_wrong_sort_field
    assert_raises(ItemsHandler::NoFieldError) { @handler.sort('bad_field') }
  end

  def test_wrong_filter_field
    assert_raises(ItemsHandler::NoFieldError) { @handler.filter('bad_field', 'some_value') }
  end

end


# START HERE
class ItemsHandler

  class PaginateParamError < StandardError; end
  class NoItemsError       < StandardError; end
  class NoFieldError       < StandardError; end

  def initialize(*cars)
     @cars = cars
     @count_cars_in_page = 10
     @first_page = 1
  end

  def paginate(number_of_page)
    @number_of_page = number_of_page

    raise ItemsHandler::PaginateParamError if @number_of_page < @first_page
    raise ItemsHandler::NoItemsError       if @number_of_page > last_page_number
  end

  def current_page
    @number_of_page
  end

  def prev_page_number
    @number_of_page == @first_page ? last_page_number : current_page.pred
  end

  def next_page_number
    @number_of_page == last_page_number ? @first_page : current_page.next
  end

  def last_page_number
    @cars.flatten.count / @count_cars_in_page
  end

  def sort(*params)
    raise ItemsHandler::NoFieldError unless params.include?(:price)

    if params.include?(:desc)
      @cars = @cars.sort_by { |key| -key[params[0]] }
    else
      @cars = @cars.sort_by { |key| key[params[0]] }
    end
    self
  end

  def filter(*params)
    raise ItemsHandler::NoFieldError unless params.include?(:color)
    raise ItemsHandler::NoFieldError if     params.include?('some_value')

    @cars = @cars.select{ |key| key[0] == params[1] }
    self
  end

  def items
    @cars
  end
end
