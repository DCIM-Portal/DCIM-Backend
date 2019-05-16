class CreateRacks
  def self.call(rack)
    new(rack).call
  end

  def initialize(rack)
    @rack = rack
  end

  def call
    return false unless !@rack.name.empty? &&
                        !@rack.amount.empty? &&
                        @rack.amount.to_i.positive? &&
                        !@rack.start_at.empty? &&
                        @rack.start_at.to_i >= 0 &&
                        @rack.zero_pad_to.to_i >= 0

    ActiveRecord::Base.transaction do
      @rack.amount.to_i.times do |i|
        create_object(i)
      end
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  def create_object(index)
    rack = EnclosureRack.new do |model|
      number = (@rack.start_at.to_i + index)
      padding = 1 + @rack.zero_pad_to.to_i
      padded_number = format("%0#{padding}i", number)
      model.name = @rack.name.strip + padded_number.to_s
      model.orientation = 180
      model.height = @rack.height.to_i
      model.zone_id = @rack.zone_id
    end
    rack.save!
  end
end
