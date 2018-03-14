class Admin::VisualDcController < AdminController
  before_action :determine_scene, only: %i[show]


  def index; end

  def show
    model_class_name = @model_name.camelize
    model_class = model_class_name.constantize
    model = model_class.find(@model_id)

    @racks = model.enclosure_racks

    respond_to do |format|
      format.html
      format.json { render json: @racks }
    end
  end

  private

  def determine_scene
    keys = params.keys.select { |key| key.end_with?('_id') }
    key = keys.last
    @model_name = key.chomp('_id')
    @model_name_plural = @model_name.pluralize
    @model_id = params[key]
  end
end
