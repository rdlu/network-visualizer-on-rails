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
    Yell.new(:gelf, :facility => 'netmetric').info 'Update do Top100 Sites iniciando...'
  end

  def after(job)
    Yell.new(:gelf, :facility => 'netmetric').info 'Update do Top100 Sites encerrado'
  end

  def success(job)
    Yell.new(:gelf, :facility => 'netmetric').info 'Update do Top100 Sites encerrado com sucesso'
  end

  def error(job, exception)
    Yell.new(:gelf, :facility => 'netmetric').info 'Bad server, no donut for you [Update Top100 falhou]'
  end

  def failure

  end
end
