require 'RestClient'
require 'json'

@hapikey = ARGV[0] || ENV['HAPIKEY']

def list_pages(offset = 0)
  RestClient.get "http://api.hubapi.com/content/api/v2/pages/",
  {:params => {
    :hapikey => @hapikey,
    "limit" => 100,
    "offset" => offset
    }
  }
end

def parse_pages(offset = 0)
  puts "Offset: #{offset}"

  # get batch of pages
  pages = JSON.parse(list_pages(offset))['objects']
  
  if pages.size > 0
    # for every page
    pages.each do |page|
      save_page(page)
    end

    offset += pages.size

    # try another batch
    parse_pages(offset)
  end
end

def save_page(page)
  # get page name
  fullname = page['html_title']
  # safe_fullname = fullname.gsub(/[\/]/, '-')
  
  # sanitize filename if page title is present
  safe_fullname = nil
  if fullname
    safe_fullname = sanitize_filename(fullname)
  end

  # save blogpost data to file
  puts "Saving ./content/Pages/#{page['id']}-#{safe_fullname}.json"

  File.open("./content/Pages/#{page['id']}-#{safe_fullname}.json", 'w') { |file| file.write(page.to_json) }
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

unless Dir.exist? "content/Pages"
  Dir.mkdir "content/Pages"
end

parse_pages