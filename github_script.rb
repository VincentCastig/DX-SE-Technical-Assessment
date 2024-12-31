require 'net/http'
require 'json'
require 'csv'
require 'dotenv/load'

GITHUB_TOKEN = ENV['GITHUB_TOKEN']
REPO = 'VincentCastig/DX-SE-Technical-Assessment'


def fetch_pull_requests
  uri = URI("https://api.github.com/repos/#{REPO}/pulls?state=closed")
  req = Net::HTTP::Get.new(uri)
  req['Authorization'] = "token #{GITHUB_TOKEN}"
  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

  JSON.parse(res.body)
end


def generate_csv(prs)
  CSV.open("pull_requests.csv", "wb") do |csv|
    csv << ["Author", "Merger", "Additions", "Deletions", "Created At", "Merged At", "Time Difference (hrs)"]
    prs.each do |pr|
      author = pr['user']['login']
      merger = pr['merged_by'] ? pr['merged_by']['login'] : 'N/A'
      additions = pr['additions']
      deletions = pr['deletions']
      created_at = pr['created_at']
      merged_at = pr['merged_at']
      time_diff = merged_at ? ((Time.parse(merged_at) - Time.parse(created_at)) / 3600).round(2) : 'N/A'

      csv << [author, merger, additions, deletions, created_at, merged_at, time_diff]
    end
  end
end

# Main Execution
pull_requests = fetch_pull_requests
generate_csv(pull_requests)
puts "CSV generated: pull_requests.csv"
