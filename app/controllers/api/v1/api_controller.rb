class Api::V1::ApiController < ApplicationController
  def index
    render json: model.all.as_json
  end

  def create
    # todo
  end

  def update
    # todo
  end

  def destroy
    # todo
  end

  protected

  def model
    @model ||= self.class.name.demodulize.sub(/Controller$/, '').singularize.constantize
  end
end
