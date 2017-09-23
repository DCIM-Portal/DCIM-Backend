class System < ApplicationRecord
  has_one :bmc_host

  enum sync_status: {
    success: 0,
    in_progress: 1,
    stack_trace: 2,
    record_error: 3
  }

  @@sync_attribute_names = %w[cpu_model cpu_cores cpu_threads cpu_count ram_total disk_total disk_count os os_release]
  class << self
    attribute_to_fact_map = {
      cpu_model: %w[processor0 cpu_model],
      # XXX: Next line appears to be impossible. Remove from model?
      #      cpu_cores: [],
      cpu_threads: %w[num_cpus processorcount],
      # XXX: Next line only works with Puppet facts currently
      cpu_count: ['physicalprocessorcount'],
      #      ram_total: ['mem_total'],
      #      disk_total: [],
      #      disk_count: [],
      os: ['os::name', 'os'],
      os_release: ['os::release::full', 'osrelease']
    }

    @@sync_attribute_names.each do |attribute_name|
      next unless attribute_to_fact_map[attribute_name.to_sym].is_a? Array
      define_method :"#{attribute_name}_from_facts" do |facts|
        attribute_to_fact_map[attribute_name.to_sym].each do |fact_name|
          return facts[fact_name] if facts[fact_name]
        end
        nil
      end
    end
  end

  def refresh!
    self.sync_status = :in_progress
    self.error_message = nil
    save!
    facts = fetch_facts
    @@sync_attribute_names.each do |attribute_name|
      attribute_value = determine_attribute_value(attribute_name, facts)
      send("#{attribute_name}=", attribute_value) unless attribute_value.nil?
    end
    self.sync_status = :success
    save!
  rescue Dcim::RecordError => e
    self.sync_status = :record_error
    self.error_message = e.class.name + ': ' + e.message + "\n" + e.backtrace.join("\n")
    save!
  rescue RuntimeError => e
    self.sync_status = :stack_trace
    self.error_message = e.class.name + ': ' + e.message + "\n" + e.backtrace.join("\n")
    save!
  end

  def fetch_facts
    reply = Dcim::ForemanApiFactory.instance.api.hosts(foreman_host_id).facts.get(payload: { per_page: 100_000_000 }.to_json)
    keys = reply['results'].try :keys
    raise Dcim::DuplicateRecordError, "1 expected, #{keys.length} returned" if keys.length > 1
    raise Dcim::MissingRecordError, "1 expected, #{keys.length} returned" if keys.length <= 0
    _name, facts = reply['results'].first
    facts
  end

  def determine_attribute_value(attribute_name, facts)
    output = self.class.send("#{attribute_name}_from_facts", facts) if self.class.respond_to? "#{attribute_name}_from_facts"
    return output if output
    return send("determine_#{attribute_name}", facts) if respond_to? "determine_#{attribute_name}"
    nil
  end

  def determine_ram_total(facts)
    ram_total_mb = nil
    %w[mem_total memorysize_mb].each do |fact_name|
      ram_total_mb ||= facts[fact_name]
    end
    return nil unless ram_total_mb
    ram_total_mb.to_f * 1000 * 1000
  end
end
