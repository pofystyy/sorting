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

  # PAGINATE
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


  # SORT
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

  # FILTER
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

  # RAISE
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

  def initialize(cars)
     @cars = 100.times.inject([]) do |arr, i| arr.push(
      id: i,
      price: rand(1000..25000),
      color: [:red, :blue, :white, :yellow, :black][rand(5)]
    )
    end
  end

  # PAGINATE
  #test_paginate
  def paginate(number_cars)
    @number_cars = number_cars
    @page = @cars[number_cars - 1]
    last_page = last_page_number
    raise ItemsHandler::PaginateParamError if number_cars < 1
    raise ItemsHandler::NoItemsError       if number_cars > last_page
  end

  def current_page
    @page[:id] + 1
  end

  def paginated_cars
  end

  #test_prev_page_number_calculation
  def prev_page_number
    return last_page_number if @number_cars == 1
    current_page - 1
  end

  #test_next_page_number_calculation
  def next_page_number
    return 1 if @number_cars == last_page_number
    current_page + 1
  end

  #test_last_page_number_calculation
  def last_page_number
    @cars.count / 10
  end

  # SORT
  def sort(*params)
    return @cars.sort_by { |hsh| -hsh[:price] } if params.include?(:desc)
    @cars.sort_by { |hsh| hsh[:price] }
  end
end