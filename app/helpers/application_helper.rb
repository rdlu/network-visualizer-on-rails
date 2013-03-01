module ApplicationHelper

  def title(page_title)
    content_for(:title) { "NetMetric MoM :: "+page_title }
  end

  def habtm_checkboxes(obj, column, assignment_objects, assignment_object_display_column)
    obj_to_s = obj.class.to_s.split("::").last.underscore
    field_name = "#{obj_to_s}[#{column}][]"

    html = hidden_field_tag(field_name, "")
    assignment_objects.each do |assignment_obj|
      cbx_id = "#{obj_to_s}_#{column}_#{assignment_obj.id}"
      html += check_box_tag field_name, assignment_obj.id, obj.send(column).include?(assignment_obj.id), :id => cbx_id
      html += label_tag cbx_id, h(assignment_obj.send(assignment_object_display_column))
      html += content_tag(:br)
    end
    html
  end

  def schedule_for_probes(source, destination)
    end_json = Hash.new
    end_json[destination] = Hash.new
    
    # Lê do cache
    probe = Rails.cache.fetch("probe_#{destination}") do
      # Este bloco será retornado APENAS no caso de um cache miss
      Probe.find(destination).to_json
    end
    
    end_json[destination][:probe] = ActiveSupport::JSON.decode(probe)

    ###########

    kpi = Rails.cache.fetch("kpi_#{destination}") do
      Kpi.where(:destination_id => destination)
    end

    end_json[destination][:kpi] = ActiveSupport::JSON.decode(kpi) 

    ###########

    schedule = Rails.cache.fetch("schedule_#{source}_#{destination}") do
      Schedule.
        where(destination_id: destination).
        where(source_id: source).
        all.last.to_json
    end

    sj = ActiveSupport::JSON.decode(schedule)
    end_json[destination][:schedules] = Hash.new
    end_json[destination][:schedules][sj[:id]] = sj

    ###########

    results = Rails.cache.fetch("results_#{source}_#{destination}") do
      Result.where(schedule_id: schedule[:id])
    end

    end_json[destination][:results] = ActiveSupport::JSON.decode(results)

    ###########
    
    end_json
  end

  def schedule_for_all_probes
    all_probes = Array.new

    Schedule.all.each do |s|
      all_probes << schedule_for_probes(s.source_id, s.destination_id)
    end

    all_probes
  end

end
