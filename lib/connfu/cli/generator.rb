require 'connfu/listener_channel'

module Connfu
	##
	# This module helps a client to manage connFu applications
  module Cli
    module Generator
      
      VOICE_CHANNEL=<<END

      listen(:voice) do |conference|
        conference.on(:join) do |call|
          puts "New inbound call from \#{call[:from]} on number \#{call[:to]}"
        end

        conference.on(:leave) do |call|
          puts "\#{call[:from]} has left the conference \#{call[:channel_name]}"
        end

        conference.on(:new_topic) do |topic|
          puts "New topic in the conference \#{topic[:channel_name]}: \#{topic[:content]}"
        end
      end

END
      TWITTER_CHANNEL=<<END
      
      listen(:twitter) do |twitter|
            twitter.on(:new) do |tweet|
                puts "\#{tweet[:channel_name]} just posted a new tweet in the conference room: \#{tweet.content}"
            end
      end
      
END
      SMS_CHANNEL=<<END

      listen(:sms) do |sms|
            sms.on(:new) do |message|
                puts "New inbound sms from \#{message[:from]}: \#{message[:content]}"
            end
      end

END

      RSS_CHANNEL=<<END

      listen(:rss) do |rss|
            rss.on(:new) do |post|
                puts "New post with title \#{post[:channel_name]} in the blog \#{post[:bare_uri]}"
            end
      end

END

      APPLICATION_TEMPLATE=<<END

  require 'connfu'

  ##
  # This application is an example of how to create a connFu application

  token = "YOUR-VALID-CONNFU-TOKEN"

  Connfu.logger = STDOUT
  Connfu.log_level = Logger::DEBUG

  Connfu.application(token) {
  %{channels}
  }

END
      
      class << self
        ##
        #
        # ==== Parameters
        # * **name** application name
        # * **channels** channels the application should listen to
        # * **file_name** main file that will hold the application logic
        #
        # ==== Return
        def run(name, channels = nil, file_name = "application.rb")

          channels.is_a?(String) and channels = channels.split.map{|channel| channel.to_sym}
          
          channels_templates = {:voice => VOICE_CHANNEL, :sms => SMS_CHANNEL, :twitter => TWITTER_CHANNEL, :rss => RSS_CHANNEL}

          code = APPLICATION_TEMPLATE.dup

          if channels.nil?
            channels = channels_templates.values.join
          else
            channels.delete_if{|channel| !Connfu::ListenerChannel::CHANNEL_TYPES.include?(channel)}
            channels = channels.map{|item| channels_templates[item]}.join
          end
          values = {:channels => channels}
          
          code.gsub!(/%\{(\w+)\}/) do |match|
            key = $1
            values[key.to_sym]
          end
          puts code
          exit
          
          Dir.mkdir(name)
            Dir.chdir(name) do
            File.open(file_name, 'w') do |f|
              f.write(code)
            end
          end
        end # end:run
      end # end class level
    end # end module Generator
  end # end module Cli
end