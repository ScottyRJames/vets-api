# frozen_string_literal: true

module EventStream
  class EventProducer
    NAMESPACE = REDIS_CONFIG[:event_stream][:namespace]
    MAXLEN = REDIS_CONFIG[:event_stream][:maxlen]

    def add(event)
      # RedisNamespace gem does not namespace XADD
      redis.xadd("#{NAMESPACE}:incoming", { payload: event }, maxlen: MAXLEN, approximate: true)
    end

    private

    def redis
      @redis ||= Redis.current
    end
  end
end
