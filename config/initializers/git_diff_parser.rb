require 'regex_parser'

class DiffParser < RegexParser
  attr_accessor :file
  attr_accessor :action # :created, :updated, :deleted
end

class DiffUnit
  attr_accessor :file, :linenum, :action, :line

  def initialize(data = {})
    @file, @linenum, @action, @line = data.values_at(:file, :linenum, :action, :line)
  end

  def to_hash
    {
      file: @file,
      linenum: @linenum,
      action: @action,
      line: @line
    }
  end
end

DIFF_PARSER = DiffParser.new

DIFF_PARSER.add /\@\@ ([\-|\+]{1}\d+)\,(\d+) ([\-|\+]{1}\d+)\,(\d+) \@\@/ do |left_start, left_len, right_start, right_len|
  @left_start = left_start.to_i.abs
  @right_start = right_start.to_i.abs
end

DIFF_PARSER.add /\A\-\-\- \/dev\/null\Z/ do
  @action = :created
end

DIFF_PARSER.add /\A\-\-\- a\/(.*?)\Z/ do |left_file|
  left_file = left_file.first

  @file = left_file
  @action = :updated
end

DIFF_PARSER.add /\A\+\+\+ \/dev\/null\Z/ do
  @action = :deleted
end

DIFF_PARSER.add /\A\+\+\+ b\/(.*?)\Z/ do |right_file|
  right_file = right_file.first

  @file = right_file
end

DIFF_PARSER.add /\A\-(.*)\Z/ do |line|
  line = line.first
  #puts "[#{@file}] Deleted at line #{@left_start}: #{line}"
  diff = DiffUnit.new(
    file: @file,
    linenum: @left_start,
    action: :delete,
    line: line
  )
  @left_start += 1

  diff
end

DIFF_PARSER.add /\A\+(.*)\Z/ do |line|
  line = line.first

  #puts "[#{@file}] Added at line #{@right_start}: #{line}"
  diff = DiffUnit.new(
    file: @file,
    linenum: @right_start,
    action: :add,
    line: line
  )
  @right_start += 1

  diff
end

DIFF_PARSER.add /\A\Z/ do |line|
  if (@left_start && @right_start)
    @left_start += 1
    @right_start += 1
  end
end
