module OpalDevtools
  # format completion in columns, like MRI irb
  class CompletionFormatter
    def self.format(choices, width = 80)
      new.format(choices, width)
    end

    def in_groups_of(array, number, fill_with = nil)
      number = number.to_i

      if fill_with == false
        collection = array
      else
        # size % number gives how many extra we have;
        # subtracting from number gives how many to add;
        # modulo number ensures we don't add group of just fill.
        padding = (number - array.size % number) % number
        collection = array.dup.concat(Array.new(padding, fill_with))
      end

      if block_given?
        collection.each_slice(number) { |slice| yield(slice) }
      else
        collection.each_slice(number).to_a
      end
    end

    def format(choices, width = 80)
      max_length = choices.inject(0) { |length, element| element.size > length ? element.size : length}
      num_cols = (width/(max_length+1)).floor # coz this is JS

      num_cols -= 1 if max_length * num_cols == width && !(num_cols < 2)
      num_cols  = 1 if num_cols < 1

      column_width = max_length + ((width - (max_length * num_cols))/num_cols).floor

      groups = in_groups_of(choices.sort, num_cols, false)
      groups.map { |grouping| grouping.map { |choice| sprintf("%-#{column_width}s", choice) }.join }.join("\n") + "\n"
    end
  end
end
