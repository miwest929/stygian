module Github
  extend self

  @last_response = nil
  @repo = nil

  def load_commits(repo)
    @repo = repo
    @last_response = nil

    earliest_commit = Date.today
    while (commits = next_commits)
      commits.each do |c|
        author = c.author || c.committer
        commit_date = c.commit.committer.date
        earliest_commit = commit_date if commit_date < earliest_commit
        begin
          COUCHDB_DB.save_doc(
            '_id' => "#{repo}|#{c.sha}",
            'sha' => c.sha,
            'author' => author.login,
            'date' => commit_date,
            'message' => c.commit.message,
            'repo_name' => repo,
            'parent' => c.parents.map {|p| p.sha}.to_json
          )
          puts "Stored commit #{c.sha} of #{repo} in CouchDB."
        rescue => e # RestClient::ResourceConflict
          puts "Failed to store commit #{c.sha} of #{repo} in CouchDB because: #{e.message}"
        end
      end
    end

    puts "Earliest commit found #{earliest_commit}"

    @repo = @last_response = nil
  end

  def load_patches(repo)
    all_docs = COUCHDB_DB.documents['rows'].map { |info| COUCHDB_DB.get(info['key']) }
    no_patch_docs = all_docs.reject {|d| d.keys.include?('patch')}
    puts "#{no_patch_docs.count} commits missing the patch"

    no_patch_docs.each do |doc|
      puts "Retrieving and setting patch for commit #{doc['sha']} in repo #{repo}"

      COUCHDB_DB.update_doc(doc['_id']) do |d|
        d[:patch] = get_patch( repo, d['sha'] )
        d
      end
    end
  end

private
  def get_patch(repo, commit_sha)
    result = GITHUB.commit(repo, commit_sha)

    return [] if result.files.nil?

    result.files.map { |f| {filename: f[:filename], patch: f[:patch]} }
  end

  def next_commits
    @last_response ? invoke_hypermedia_next_link : invoke_initial_call
  end

  def invoke_initial_call
    raise "No repo is specified!" unless @repo
    commits = GITHUB.commits(@repo)
    @last_response = GITHUB.last_response

    commits
  end

  def invoke_hypermedia_next_link
    return nil unless @last_response.rels[:next]

    next_response = @last_response.rels[:next].get

    @last_response = next_response
    next_response.data
  end
end
