module MicroService
  class CommitCount
    attr_accessor :commit_counts

    def initialize
      @commit_counts = Hash.new(0)
      @file = File.open("#{Rails.root}/tmp/commit.txt", "w")
    end

    def process(message)
      data = JSON.parse(message)
      repo, sha = data['_id'].split('|')
      author = data['author']
      @commit_counts[author] += 1
      @file.write("#{repo} - #{author}: #{@commit_counts[author]}\n")
    end
  end
end
