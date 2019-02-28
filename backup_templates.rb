require 'RestClient'
require 'json'

@hapikey = ARGV[0] || ENV['HAPIKEY']

def list_layouts(offset = 0)
  RestClient.get "http://api.hubapi.com/content/api/v2/layouts",
  {:params => {
    :hapikey => @hapikey,
    "limit" => 100,
    "offset" => offset
    }
  }
end

def parse_layouts(offset = 0)
  puts "Offset: #{offset}"

  # get batch of layouts
  layouts = JSON.parse(list_layouts(offset))['objects']
  
  if layouts.size > 0
    # for every layout
    layouts.each do |layout|
      save_layout(layout)
    end

    offset += layouts.size

    # try another batch
    parse_layouts(offset)
  end
end

def save_layout(layout)
  # get page name
  fullname = layout['label']
  # safe_fullname = fullname.gsub(/[\/]/, '-')
  
  # sanitize filename if page title is present
  safe_fullname = nil
  if fullname
    safe_fullname = sanitize_filename(fullname)
  end

  # save blogpost data to file
  puts "Saving ./templates/layouts/#{layout['id']}-#{safe_fullname}.json"

  File.open("./templates/layouts/#{layout['id']}-#{safe_fullname}.json", 'w') { |file| file.write(layout.to_json) }
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

unless Dir.exist? "templates/layouts"
  FileUtils.mkdir_p "templates/layouts"
end

parse_layouts