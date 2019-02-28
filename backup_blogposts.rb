require 'RestClient'
require 'json'

@hapikey = ARGV[0] || ENV['HAPIKEY']

def list_blogs(offset = 0)
  RestClient.get "http://api.hubapi.com/content/api/v2/blogs/",
  {:params => {
    :hapikey => @hapikey,
    "limit" => 100,
    "offset" => offset
    }
  }
end

def list_blogposts(blog_id, offset = 0)
  RestClient.get "http://api.hubapi.com/content/api/v2/blog-posts/",
  {:params => {
    :hapikey => @hapikey,
    "content_group_id" => blog_id,
    "limit" => 100,
    "offset" => offset
    }
  }

end

def parse_blogposts(blog, offset)
  puts "Offset: #{offset}"

  # get blogposts from current blog
  posts = JSON.parse(list_blogposts(blog['id'], offset))['objects']
  
  if posts.size > 0
    posts.each do |post|
      save_blogpost(blog, post)
    end

    offset += posts.size
    
    # try another batch
    parse_blogposts(blog, offset)
  end
end

def save_blogpost(blog, post)
  # get blogpost name
  fullname = post['html_title']
  # safe_fullname = fullname.gsub(/[\/]/, '-')
  safe_fullname = sanitize_filename(fullname)

  # save blogpost data to file
  puts "Saving ./content/#{blog['name']}/#{safe_fullname}.json"

  File.open("./content/#{blog['name']}/#{post['id']}-#{safe_fullname}.json", 'w') { |file| file.write(post.to_json) }
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

blogs = JSON.parse(list_blogs)['objects']

# for every blog
blogs.each do |blog|
  # create directory if it doesn't exist
  unless Dir.exist? "content/#{blog['name']}"
    FileUtils.mkdir_p "content/#{blog['name']}"
  end

  # start from the beginning
  offset = 0

  parse_blogposts(blog, offset)
end