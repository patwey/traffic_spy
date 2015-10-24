module TrafficSpy
  class Statistics

    def self.application_details(payloads)
      urls = get_ranked_urls(payloads)
      browsers, op_systems = parse_user_agents(payloads)
      resolutions = get_ranked_resolutions(payloads)
      response_times = get_avg_response_time_by_url(payloads)
      { urls: urls,
        browsers: browsers,
        op_systems: op_systems,
        resolutions: resolutions,
        response_times: response_times }
    end

    def self.order_collection(collection)
      collection_count = Hash.new(0)
      collection.each do |element|
        collection_count[element] += 1
      end
      collection_count.sort_by { |k, v| v}.reverse
    end

    def self.get_ranked_browsers(user_agents)
      raw_browsers = user_agents.map { |user_agent| user_agent.browser }
      order_collection(raw_browsers)
    end

    def self.get_ranked_op_systems(user_agents)
      raw_op_systems = user_agents.map { |user_agent| user_agent.os }
      op_systems = order_collection(raw_op_systems)
    end

    def self.parse_user_agents(payloads)
      user_agent_strings = payloads.map { |payload| payload.user_agent }
      user_agents = user_agent_strings.map { |string| UserAgent.parse(string) }
      browsers = get_ranked_browsers(user_agents)
      op_systems = get_ranked_op_systems(user_agents)
      [browsers, op_systems]
    end

    def self.get_ranked_urls(payloads)
      raw_urls = payloads.map { |payload| TrafficSpy::Url.find_by(id: payload.url_id).url }
      order_collection(raw_urls)
    end

    def self.get_ranked_resolutions(payloads)
      #store as integers or numbers?
      raw_screen_resolutions = payloads.map { |payload| "#{payload.resolution_width} x #{payload.resolution_height}" }
      order_collection(raw_screen_resolutions)
    end

    def self.get_avg_response_time_by_url(payloads)
      urls = payloads.map { |payload| TrafficSpy::Url.find_by(id: payload.url_id) }.uniq
      avg_response_time_by_url = {}
      urls.each do |url|
        response_times = []
        payloads.each do |payload|
          if payload[:url_id] == url.id
            response_times << payload[:responded_in].to_f
          end
        end
        avg_response_time_by_url[url.url] = response_times.reduce(:+) / response_times.size
      end
      avg_response_time_by_url.sort_by { |k, v| v }.reverse
    end
  end
end
