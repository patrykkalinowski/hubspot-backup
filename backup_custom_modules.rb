require 'RestClient'
require 'json'

@hapikey = ARGV[0] || ENV['HAPIKEY']

def list_widgets(offset = 0)
  RestClient.get "http://api.hubapi.com/designmanager/v1/custom-widgets/",
  {:params => {
    :hapikey => @hapikey,
    "limit" => 100,
    "offset" => offset
    }
  }
end

def parse_widgets(offset = 0)
  puts "Offset: #{offset}"

  # get batch of widgets
  widgets = JSON.parse(list_widgets(offset))['objects']
  
  if widgets.size > 0
    # for every widget
    widgets.each do |widget|
      save_widget(widget)
    end

    offset += widgets.size

    # try another batch
    parse_widgets(offset)
  end
end

def save_widget(widget)
  # get page name
  fullname = widget['name']
  # safe_fullname = fullname.gsub(/[\/]/, '-')
  
  # sanitize filename if page title is present
  safe_fullname = nil
  if fullname
    safe_fullname = sanitize_filename(fullname)
  end

  # save blogpost data to file
  puts "Saving ./templates/custom-widgets/#{widget['id']}-#{safe_fullname}.json"

  File.open("./templates/custom-widgets/#{widget['id']}-#{safe_fullname}.json", 'w') { |file| file.write(widget.to_json) }
end

def sanitize_filename(filename)
  # Split the name when finding a period which is preceded by some
  # character, and is followed by some character other than a period,
  # if there is no following period that is followed by something
  # other than a period (yeah, confusing, I know)
  fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m

  # We now have one or two parts (depending on whether we could find
  # a suitable period). For each of these parts, replace any unwanted
  # sequence of characters with an underscore
  fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }

  # Finally, join the parts with a period and return the result
  return fn.join '.'
end

unless Dir.exist? "templates/custom-widgets"
  FileUtils.mkdir_p "templates/custom-widgets"
end

parse_widgets