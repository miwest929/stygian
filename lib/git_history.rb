module GitHistory
  extend self

  # Given a github repo link the repo will be cloned and it's git commit history will
  # be parsed for further visualization.
  # If 'path' points to a real GitHub repo then a Repo object will be returned
  # otherwise nil is returned.
  def parse(path)
    begin
      # tag is the GitHub repo name
      tag = /\/(.*)\.git/.match(path)[1]
      raise "Repo with tag '#{tag}' is already registered." if Repo.find_by_tag(tag)

      system("cd #{Rails.root}/tmp && git clone #{path} && cd #{tag} && git log > temphist.txt")
      repo = parse_git_history(tag)

      # For each commit and it's diff parse
      repo.for_each_commit do |commit, diff|
        changes = parse_commit_diff(diff)
        puts changes
      end
    ensure
      puts "Cleaning up..."
      system("rm -Rf #{Rails.root}/tmp/#{tag}")
    end
  end

protected
  def parse_commit_line(line, keyword)
    if line.starts_with?(keyword)
      value = line[(keyword.length)..-1].strip
      yield(value) if block_given?
    end
  end

  # Returns a Repo object
  def parse_git_history(name)
    repo = Repo.new(tag: name)

    repo.commits = []
    current_commit = nil
    File.readlines("#{Rails.root}/tmp/#{name}/temphist.txt").each do |line|
      # Start of new commit
      parse_commit_line(line, 'commit') do |value|
        current_commit.save && repo.commits << current_commit if current_commit

        current_commit = GitCommit.new(commit_id: value, message: "")
      end

      parse_commit_line(line, 'Author:') {|value| current_commit.author = value}
      parse_commit_line(line, 'Date:') {|value| current_commit.commit_date = value}

      #TODO: Store the commit message as well
      #else
      #  current_commit.message += line
      #end
    end

    current_commit.save && repo.commits << current_commit if current_commit

    repo.save
    repo
  end

  def parse_commit_diff(diff)
    empty_file = '/dev/null'

    commit_changes = {}
    change_type = nil
    filename = nil
    diff.each do |line|
      parse_commit_line(line, '---') do |value|
        filename = change_type = nil
        change_type = if value == empty_file
          "NEW"
        else
          filename = value[2..-1]
          "UPDATE"
        end
      end

      parse_commit_line(line, '+++') do |value|
        if value == empty_file
          change_type = "REMOVE"
        elsif filename.nil?
          filename = value[2..-1]
        end

        commit_changes[filename] = change_type
      end

    end

     commit_changes
  end
end
