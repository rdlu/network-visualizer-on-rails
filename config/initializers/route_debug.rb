
def show_routes(match = nil)
  Rails.application.reload_routes!
  all_routes = Rails.application.routes.routes

  require 'rails/application/route_inspector'
  inspector = Rails::Application::RouteInspector.new

  routes = inspector.format(all_routes, ENV['CONTROLLER'])

  ansi_bold       = "\033[1m"
  ansi_reset      = "\033[0m"

  if (match)
    match = match.to_s
    puts routes.grep(/#{match}/).map { |r|
      r.gsub!(match, "#{ansi_bold}#{match}#{ansi_reset}")
    }.join("\n")

  else
    puts routes.join "\n"
  end
end

def reload_routes
  Rails.application.reload_routes!
end