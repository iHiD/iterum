module Iterum
  class MessageReplayer

    def self.reprocess_failed(application_name, topic_name, count=1)
      new(application_name, topic_name).reprocess_failed(count)
    end

    def initialize(application_name, topic_name)
      @application_name = application_name
      @topic_name = topic_name
      @sqs = Fog::AWS::SQS.new(Propono.aws_options)
    end

    def reprocess_failed(count)
      Filum.logger.info "Reprocessing #{count} message(s) for topic: #{@topic_name} application: #{@application_name} queue_suffix: #{Propono.config.queue_suffix}"

      raise StandardError.new "Queue does not exist." unless queue_exists?

      subscription = Propono::QueueSubscription.create(@topic_name)
      original_url = subscription.queue.url
      failed_url = subscription.failed_queue.url

      count_left = count.to_i

      while count_left > 0 do
        response = @sqs.receive_message( failed_url, {'MaxNumberOfMessages' => 10} )
        messages = response.body['Message']
        if messages.empty?
          raise StandardError.new "Message empty"
        else
          messages.each do |msg|
            if count_left > 0
              sqs_message = Propono::SqsMessage.new(msg)
              puts "Message : #{sqs_message}"
              @sqs.send_message(original_url, sqs_message.to_json_with_exception(StandardError.new "Fake Exception"))
              @sqs.delete_message(failed_url, msg['ReceiptHandle'])
              count_left = count_left - 1
            end
          end
        end
      end
    end

    def queue_exists?
      queue_exists = false
      failed_queue_exists = false
      response = @sqs.list_queues
      queue_urls = response.body.fetch('QueueUrls')
      queue_urls.each do |queue|
        queue_exists = true if queue.match(Regexp.new "#{@application_name}-#{@topic_name}$")
        queue_exists = true if queue.match(Regexp.new "#{@application_name}-#{@topic_name}#{Propono.config.queue_suffix}$")
        failed_queue_exists = true if queue.match(Regexp.new "#{@application_name}-#{@topic_name}-failed$")
        failed_queue_exists = true if queue.match(Regexp.new "#{@application_name}-#{@topic_name}#{Propono.config.queue_suffix}-failed$")
      end
      queue_exists && failed_queue_exists
    end
  end
end
