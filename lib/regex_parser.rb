class RegexRule
  attr_accessor :regex
  attr_accessor :response
  attr_accessor :last_diff

  def initialize(regex, &response)
    @regex = regex
    @response = response
  end

  def match(line)
    result = @regex.match(line)
    return nil unless result

    diff = @response.call(result.captures)
    @last_diff = diff.is_a?(DiffUnit) ? diff : nil

    true
  end
end

class RegexParser
  attr_accessor :rules

  def initialize
    @rules = []
  end

  def parse(path)
    for_each_line(path)
  end

  def add(regex, &response)
    @rules << RegexRule.new(regex, &response)
  end
private
  def for_each_line(path)
    diffs = []
    File.readlines(path).each do |line|
      r = match_with_rules(line)
      r && (diffs << r)
    end

    diffs
  end

  # Tries every registered regex rule until one matches.
  # Once a regex rule is matched further processing is halted and
  # the matched rule is returned.
  # Return nil is no rule was matched.
  def match_with_rules(line)
    matched_rule = @rules.detect {|rule| rule.match(line)}
    matched_rule ? matched_rule.last_diff : nil
  end
end
