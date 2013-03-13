# coding: utf-8

class UpdateTop100Exception < Exception

end

class UpdateTop100
  def initialize

  end

  def enqueue(job)

  end

  def perform
    # For each page
    (0..4).each do |page|
      # open said page
      doc = Nokogiri::HTML(open("http://www.alexa.com/topsites/countries;#{page}/BR"))

      # find the container
      doc.css('div.desc-container').each do |site|
        # the <h2> has the site name
        # the topsites-label class has the URL
        puts "#{site.css('h2').first.content} - #{site.css('span.topsites-label').first.content}"
      end
    end
  end

  def before(job)

  end

  def after(job)

  end

  def success(job)

  end

  def error(job, exception)

  end

  def failure

  end
end
