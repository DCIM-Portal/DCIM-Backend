class RecordBroadcastJob < ApplicationJob
  queue_as :default

  def perform(record, **kwargs)
    serialized_record = record.as_json(include: kwargs[:associations] || record.class.reflections.keys).merge(data_extras(record)).to_json
    ActionCable.server.broadcast(record.class.name.underscore, record: record.class.name.underscore, data: serialized_record, destroyed: kwargs[:destroyed] || record.destroyed?)
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
end
