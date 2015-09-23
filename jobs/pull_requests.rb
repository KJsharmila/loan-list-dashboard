require 'octokit'
require 'time'
SCHEDULER.every '10s', :first_in => 0 do |job|

  client = Octokit::Client.new(:access_token => "8cb11a4d40bd1ba1c46be5b1121a320499a1d72f")
  my_organization = "Qwinix"
  repo_name = []

  
  client.organization_repositories(my_organization).map do |repo| 
    repo_name << repo.name if repo.name == 'loan_list'
  end

  open_pull_requests = repo_name.inject([]) { |pulls, repo|
    client.pull_requests("#{my_organization}/#{repo}", :state => 'open').each do |pull|
      pulls.push({
        title: pull.title,
        repo: repo,
        updated_at: pull.updated_at.strftime("%b %-d %Y"),
        creator: "@" + pull.user.login,
        })
    end
    pulls[0..3]
  }
  send_event('openPrs', { header: "Open Pull Requests", pulls: open_pull_requests })
end