# coding: utf-8

class UpdateTopSitesJobException < Exception

end

class UpdateTopSitesJob
  def enqueue(job)

  end

  def perform
    # Programa a próxima execução
    
    Delayed::Job.enqueue UpdateTopSitesJob.new, :queue => 'updatetop100', :run_at => DateTime.current.end_of_day

    # For each page
    (0..4).each do |page|
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
