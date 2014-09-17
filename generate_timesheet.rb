require 'slim'
require 'tilt'
require 'csv'
require 'FreshBooks'
require 'set'
require 'pp'


def generate_timesheet data
  output = Tilt.new('./timesheet.html.slim').render(data)

  #puts output

  File.open("./timesheet.html", "w") do |f|
    f.write(output)
  end
end

def get_time_entries from, to
  freshbooks_client = FreshBooks::Client.new('dropofwill.freshbooks.com', '***REMOVED***')
  data = freshbooks_client.time_entry.list(date_from: from, date_to: to, per_page: 100)

  data = data["time_entries"]["time_entry"]

  task_id = Set.new
  project_id = Set.new

  data.each do |time_entry|
    task_id.add time_entry["task_id"]
    project_id.add time_entry["project_id"]
  end

  p task_id
  p project_id

  task_hash = {}
  project_hash = {}

  task_id.each do |id|
    task_hash[id] = freshbooks_client.task.get(task_id: id)
    puts task_hash[id]
  end

  project_id.each do |id|
    project_hash[id] = freshbooks_client.project.get(project_id: id)
    puts project_hash[id]
  end

  data.each do |time_entry|
    time_entry["task"] = task_hash[time_entry["task_id"]]["task"]["name"]
    time_entry["project"] = project_hash[time_entry["project_id"]]["project"]["name"]
  end

  time_entries = data.sort_by{|obj| obj["date"]}
  pp time_entries
  return time_entries
end

cur_time_entries = get_time_entries "2014-09-01", "2014-09-14"

generate_timesheet cur_time_entries
