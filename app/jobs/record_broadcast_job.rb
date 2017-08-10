class RecordBroadcastJob < ApplicationJob
  queue_as :default

  def perform(record, **kwargs)
    data = {}
    if record.respond_to? :each
      data = records_to_hash(record, **kwargs)
      record = record.first
    else
      data = record_to_hash(record, **kwargs)
    end
    ActionCable.server.broadcast(record.class.name.underscore, record: record.class.name.underscore, data: data.to_json, destroyed: kwargs[:destroyed] || record.destroyed?)
  end

  private

  def data_extras(record)
    extras = {}
    begin
      extras.merge!({"url": record_to_url(record)})
    rescue NoMethodError
    end
    extras
  end

  def record_to_url(record)
    Rails.application.routes.url_helpers.send(record.class.name.underscore+"_path", record)
  end

  def records_to_hash(records, **kwargs)
    list = []
    records.each do |record|
      list << record_to_hash(record, **kwargs)
    end
    list
  end

  def record_to_hash(record, **kwargs)
    record.as_json(include: format_include(kwargs[:associations] || record.class.reflections.keys)).merge(data_extras(record))
  end

  def format_include(input)
    if input.is_a? Array
      output = {}
      input.each do |value|
        if value.is_a? Hash
          output.merge!({value.keys[0]=>{include: format_include(value.values[0])}})
        else
          output.merge!(format_include(value))
        end
      end
    end
    return {input=>{}} if input.is_a? String
    return format_include([input]) if input.is_a? Hash
    return output
  end

end
