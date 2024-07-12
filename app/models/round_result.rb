class RoundResult
  attr_reader :result

  def initialize
    @result = []
  end

  def add_result(result)
    @result << result
  end
end
