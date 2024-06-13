require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

file_path = '/Users/carisaelam/odin-repos/ruby/odin-event-manager/event_attendees.csv'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone(phone)
  if phone.length == 10
    phone
  elsif phone.length > 10 && phone[0] == '1'
    phone[1..-1]
  else
    phone = '0000000000'
  end
end

# def legislators_by_zipcode(zip)
#   civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
#   civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

#   begin
#     civic_info.representative_info_by_address(
#       address: zip,
#       levels: 'country',
#       roles: %w[legislatorUpperBody legislatorLowerBody]
#     ).officials
#   rescue StandardError
#     'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
#   end
# end

# def save_thank_you_letter(id, form_letter)
#   Dir.mkdir('output') unless Dir.exist?('output')
#   filename = "output/thanks_#{id}.html"
#   File.open(filename, 'w') do |file|
#     file.puts form_letter
#   end
# end

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
  # legislators = legislators_by_zipcode(zipcode)
  # form_letter = erb_template.result(binding)
  # save_thank_you_letter(id, form_letter)
end
