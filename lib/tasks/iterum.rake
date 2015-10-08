require 'active_support/core_ext'
require 'erb'
require 'yaml'

require 'propono'

namespace :iterum do

  # The command line to run this rake task is:
  #
  #  bundle exec rake iterum:reprocess_failed[<application_name>,<topic>,<count>] ENV=production
  #  e.g.
  #  bundle exec rake iterum:reprocess_failed[missito,user,1] ENV=production
  task :reprocess_failed, [:application_name, :topic_name, :count, :suffix]  do |t, args|
    application_name = args[:application_name]
    topic_name = args[:topic_name]
    count = args[:count]
    suffix = args[:suffix]

    env = ENV.fetch("ENV", "development")
    config = File.expand_path('../../../config', __FILE__)

    Filum.setup("./log/iterum.log")

    propono_config = YAML::load(ERB.new(File.read("#{config}/propono.yml")).result).stringify_keys[env].symbolize_keys

    Propono.config do |config|
      config.use_iam_profile  = propono_config[:use_iam_profile]
      config.access_key       = propono_config[:access_key]
      config.secret_key       = propono_config[:secret_key]
      config.queue_region     = propono_config[:region]
      config.application_name = application_name
      config.queue_suffix     = suffix
      config.udp_host         = "pergo.meducation.net"
      config.udp_port         = "9732"
      config.logger           = Filum.logger
    end

    Iterum::MessageReplayer.reprocess_failed(application_name, topic_name, count)
  end

end

