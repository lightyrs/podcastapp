SUNSPOT_SOLR_PID_PATH = "#{Rails.root}/tmp/pids/sunspot-solr-#{ENV['RAILS_ENV']}.pid"

def start_sunspot_solr
  Thread.new do 
    `rake sunspot:solr:start`
  end
end

def daemon_is_running?
  pid = File.read(SUNSPOT_SOLR_PID_PATH).strip
  Process.kill(0, pid.to_i)
  true
rescue  # file or process not found
  false
end

start_sunspot_solr unless daemon_is_running?