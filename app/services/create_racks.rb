class CreateRacks
  def self.call(rack)
    new(rack).call
  end

  def initialize(rack)
    @rack = rack
  end

  def call
    begin
      if @rack.name.empty? || @rack.amount.empty? || @rack.start_at.empty?
        return false
      else
        ActiveRecord::Base.transaction do
          @rack.amount.to_i.times do |i|
            create_object(i)
          end
        end
      end
    rescue ActiveRecord::RecordInvalid
      return false
    end
  end

  def create_object(i)
    rack = EnclosureRack.new do |rack|
      number = (@rack.start_at.to_i + i)
      rack.name = @rack.name.strip + "%.2d" % + number
      rack.orientation = 180
      rack.zone_id = @rack.zone_id
    end
    rack.save!
  end

end
