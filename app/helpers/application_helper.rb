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
      Kpi.where(:destination_id => destination).to_json
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
      Results.where(schedule_id: 
                    Schedule.
                      where(destination_id: destination).
                      where(source_id: source).
                      all.last).
                      last.to_json
    end

    end_json[destination][:results] = ActiveSupport::JSON.decode(results)

    ###########
    
    end_json
  end

  def schedule_for_all_probes
    all_probes = Hash.new

    Probe.order("name ASC").all.each do |probe|
      all_probes["#{probe.id}"] = Hash.new
      all_probes["#{probe.id}"][:name] = probe.name
      all_probes["#{probe.id}"][:city] = probe.city
      all_probes["#{probe.id}"][:state] = probe.state
      all_probes["#{probe.id}"][:ipaddress] = probe.ipaddress
      all_probes["#{probe.id}"][:latitude] = probe.latitude
      all_probes["#{probe.id}"][:longitude] = probe.longitude
      all_probes["#{probe.id}"][:type] = probe.type
      all_probes["#{probe.id}"][:status] = probe.status
      all_probes["#{probe.id}"][:pretty_status] = probe.pretty_status

      schedule = probe.schedules_as_destination.last

      # Caso isso permaneça nil, não temos agenda para essa probe
      all_probes["#{probe.id}"][:kpi] = nil

      unless schedule.nil? || schedule.kpis.last.nil?
        all_probes["#{probe.id}"][:kpi] = Hash.new
        all_probes["#{probe.id}"][:kpi][:uuid] = schedule.kpis.last.uuid
        all_probes["#{probe.id}"][:kpi][:brand] = schedule.kpis.last.brand
        all_probes["#{probe.id}"][:kpi][:conn_tech] = schedule.kpis.last.conn_tech
        all_probes["#{probe.id}"][:kpi][:conn_type] = schedule.kpis.last.conn_type
        all_probes["#{probe.id}"][:kpi][:dns_latency] = schedule.kpis.last.dns_latency
        all_probes["#{probe.id}"][:kpi][:lac] = schedule.kpis.last.lac
        all_probes["#{probe.id}"][:kpi][:model] = schedule.kpis.last.model
        all_probes["#{probe.id}"][:kpi][:signal] = schedule.kpis.last.signal
        all_probes["#{probe.id}"][:kpi][:timestamp] = schedule.kpis.last.timestamp.strftime("%Y-%m-%d %H:%M:%S %z")
        all_probes["#{probe.id}"][:kpi][:cell_id] = schedule.kpis.last.cell_id

        all_probes["#{probe.id}"][:results] = Hash.new
        probe.metrics.each do |metric|

          results = Results.where(:uuid => schedule.kpis.last.uuid).all.to_a

          result = results.select { |r| r.metric_id == metric.id }

          result = result.first

          all_probes["#{probe.id}"][:results]["#{metric.plugin}"] = nil

          unless result.nil?
            all_probes["#{probe.id}"][:results]["#{metric.plugin}"] = Hash.new
            all_probes["#{probe.id}"][:results]["#{metric.plugin}"][:download] = result.download
            all_probes["#{probe.id}"][:results]["#{metric.plugin}"][:upload] = result.upload
            all_probes["#{probe.id}"][:results]["#{metric.plugin}"][:timestamp] = result.timestamp.strftime("%Y-%m-%d %H:%M:%S %z")
            all_probes["#{probe.id}"][:results]["#{metric.plugin}"][:view_unit] = result.view_unit
            all_probes["#{probe.id}"][:results]["#{metric.plugin}"][:db_unit] = result.db_unit
          end
        end
      end
    end

    all_probes
  end

end
