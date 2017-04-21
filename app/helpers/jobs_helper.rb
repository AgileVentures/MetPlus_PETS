module JobsHelper
  def sort_instruction(count)
    return ' Click on any column title to sort.' if count > 1
  end
end
