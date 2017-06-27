class BmcScanJob < ApplicationJob

  queue_as :default

  def initialize(**kwargs)
    @foreman_resource = kwargs[:foreman_resource]
    @job = kwargs[:
    
