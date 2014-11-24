require 'slim'
require 'tilt'
require 'csv'
require 'FreshBooks'
require 'PDFKit'
require 'set'
require 'pp'

# Set your defaults
@first_name = "will"
@last_name = "paul"
@to = "2014-09-01"
@from = "2014-09-14"
@export_path = "/Users/willpaul/Documents/GlobalWork/TimeSheets/"

# accept command line arguments in the form @to @from
@to = ARGV[0] unless ARGV[0].nil?
@from = ARGV[1] unless ARGV[1].nil?

def main
  cur_time_entries = get_time_entries @to, @from
  cur_hours = get_hours cur_time_entries
  generate_timesheet cur_time_entries, cur_hours
end

def generate_timesheet data, hours
  entries = data
  time = { hours: hours, to: @to, from: @from }

  output = Tilt.new('./timesheet.html.slim').render(entries, time)

  path = "#{@export_path}#{@first_name}_#{@last_name}_#{@to}_#{@from}.pdf"
  puts path
  generate_pdf(output, path)

  File.open("./timesheet.html", "w") do |f|
    f.write(output)
  end
end

def get_hours data
  sum = []
  data.each { |c| sum << c["hours"].to_f }
  return sum.inject(:+)
end

def get_time_entries from, to
  freshbooks_client = FreshBooks::Client.new('dropofwill.freshbooks.com', ENV["FRESHBOOKS_API"])
  data = freshbooks_client.time_entry.list(date_from: from, date_to: to, per_page: 100)
  puts from, to

  data = data["time_entries"]["time_entry"]

  task_id = Set.new
  project_id = Set.new

  data.each do |time_entry|
    task_id.add time_entry["task_id"]
    project_id.add time_entry["project_id"]
  end

  task_hash = {}
  project_hash = {}

  task_id.each do |id|
    task_hash[id] = freshbooks_client.task.get(task_id: id)
  end

  project_id.each do |id|
    project_hash[id] = freshbooks_client.project.get(project_id: id)
  end

  data.each do |time_entry|
    time_entry["task"] = task_hash[time_entry["task_id"]]["task"]["name"]
    time_entry["project"] = project_hash[time_entry["project_id"]]["project"]["name"]
  end

  time_entries = data.sort_by{|obj| obj["date"]}
  return time_entries
end

def generate_pdf html, path
  kit = PDFKit.new(html, page_size: 'Letter', margin_top: 0, margin_bottom: 0, margin_left: 0, margin_right: 0)
  pdf = kit.to_pdf
  kit.to_file(path)
  pdf
end

# run the whole thing
main()
