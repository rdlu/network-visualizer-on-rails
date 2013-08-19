require 'open-uri'

class UpdateTopSites
  def self.perform
    Yell.new(:gelf, :facility => 'netmetric-jobs').info "Updating Top Sites"
    # For each page
    (0..3).each do |page|
      # open said page
      doc = Nokogiri::HTML(open("http://www.alexa.com/topsites/countries;#{page}/BR"))

      # find the container
      doc.css('div.desc-container').each do |site|
        # the <h2> has the site name
        site_name = site.css('h2').first.content
        # the topsites-label class has the URL
        site_url = site.css('span.topsites-label').first.content

        site = Site.find_by_url(site_url)

        unless site
          Yell.new(:gelf, :facility => 'netmetric').info "[Top100] Criando site #{site_name} com URL #{site_url}"
          site = Site.new(url: site_url, vip: false)

          if site.save
            Yell.new(:gelf, :facility => 'netmetric').info "[Top100] Site #{site_name} criado corretamente"
          else
            Yell.new(:gelf, :facility => 'netmetric').info "[Top100] Site #{site_name} não pode ser criado!"
          end
        else
          Yell.new(:gelf, :facility => 'netmetric').info "[Top100] Site #{site_name} já existe. Pulando."
        end
      end
    end
  end
end
