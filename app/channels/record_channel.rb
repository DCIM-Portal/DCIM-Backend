class RecordChannel < ApplicationCable::Channel
  def subscribed
    stream_from params[:record]
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def emit_cable(record, **kwargs)
    RecordBroadcastJob.perform_now record, **kwargs
  end

  def full_load(data)
    record_class = data['record'].classify.constantize
    if data['id']
      record_instance = record_class.find_by(id: data['id'].to_i)
      record_instance.emit_cable(associations: data['associations'])
    else
      record_instances = record_class.all
      record_instances.each do |record_instance|
        record_instance.emit_cable(associations: data['associations'])
      end
    end
  end
end
