# frozen_string_literal: true

require 'dotenv/load'
require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

file_path = '/Users/carisaelam/odin-repos/ruby/odin-event-manager/event_attendees.csv'
registration_times = []
registration_days = []
api_key = ENV['API_KEY']

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone(phone)
  if phone.length == 10
    phone
  elsif phone.length > 10 && phone[0] == '1'
    phone[1..]
  else
    '0000000000'
  end
end

def find_most_common_reg_time(registration_times)
  reg_time_objects = registration_times.map { |time| Time.parse(time) }
  hour_groups = reg_time_objects.group_by(&:hour)
  counts = hour_groups.transform_values(&:count)
  most_common_hour = counts.max_by { |_, count| count }.first
  puts "The most common hour for registrations was #{most_common_hour}. This means that most people were registering between 1:00 pm and 2:00 pm"
end

def find_most_common_reg_day(registration_days)
  parsed_dates = registration_days.map { |date| Date.strptime(date, '%m/%d/%y') }

  weekdays = parsed_dates.map(&:wday)

  most_common_weekday = weekdays.max_by { |day| weekdays.count(day) }

  days_of_week = %w[Sunday Monday Tuesady Wednesday Thursday Friday Saturday]

  most_common_day = days_of_week[most_common_weekday]
  puts "The most common day for voter registration was #{most_common_day}."
end

def legislators_by_zipcode(zip, api_key)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = api_key

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  file_path,
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('/Users/carisaelam/odin-repos/ruby/odin-event-manager/form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone = clean_phone(row[:homephone].gsub(/[^\d]/, ''))
  zipcode = clean_zipcode(row[:zipcode])
  reg_date = row[:regdate].split(' ')
  reg_time = reg_date[1]
  reg_days = reg_date[0]
  registration_times.push(reg_time)
  registration_days.push(reg_days)

  legislators = legislators_by_zipcode(zipcode, api_key)
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
end

find_most_common_reg_time(registration_times)

find_most_common_reg_day(registration_days)
