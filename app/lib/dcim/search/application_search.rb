class Dcim::Search::ApplicationSearch
  def self.search(model, params)
    page = params.delete(:page) || 0
    per_page = params.delete(:per_page) || 10

    search = model.search do
      paginate page: page, per_page: per_page
      
      # TODO
    end
  end
end
