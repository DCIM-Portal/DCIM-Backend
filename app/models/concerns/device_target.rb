module DeviceTarget
  extend ActiveSupport::Concern

  included do
    has_one :device, as: :target

    before_destroy do
      validate_associated_target
    end
  end

  def validate_associated_target
    reload
    raise ActiveRecord::ActiveRecordError, 'Device needs to be deleted first' if device.is_a?(Device) && !device.destroyed?
  end
end
