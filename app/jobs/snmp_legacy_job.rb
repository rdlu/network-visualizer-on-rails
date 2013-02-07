class SnmpLegacyJob
  def profile_setup(profile, schedule)
    config_hash = JSON.load(profile.config_parameters)
  end
end