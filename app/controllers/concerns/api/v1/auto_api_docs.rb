module Api::V1::AutoApiDocs
  extend ActiveSupport::Concern

  class_methods do
    def mock_controller
      new
    end

    def model_class
      model_class = mock_controller.send(:model_class)
    end

    def params!
      columns = model_class.column_names -
          mock_controller.send(:forbidden_write_columns).map(&:to_s)
      columns.each do |column|
        validator = case model_class.columns_hash[column].type
                      when :integer, :bigint
                        Integer
                      else
                        String
                    end
        param column, validator
      end
    end

    def collection!
      columns = model_class.column_names - mock_controller.send(:forbidden_read_columns).map(&:to_s)

      description <<-DOC
      This API method provides a list (collection) of records, which can be *paginated*, *sorted*, *searched*, and *filtered* according to the provided params, all of which are optional.

      Default results if no params are specified:
      - *Pagination:* Page 1 with a server-configured number of results per page
      - <b>Sort order:</b> Unspecified, probably in ascending order of each record's internal ID
      - *Search:* None
      - *Filters:* None

      === Pagination
      Navigate to different pages and/or change how many records are in a page.
      ==== Input Params
      - +page+ – Page number, starting from 1
      - +per_page+ – Records per page
      ==== Output Metadata
      - +pagination+ – Object complete with information about pagination position. Keys:
        - +records_count+ – Total number of records after search and filters
        - +pages_count+ – Number of pages of results
        - +records_per_page+ – Maximum number of records in the +data+ Array
        - +first_page?+ – +true+ if the +data+ Array is presenting the first page. +false+ otherwise
        - +last_page?+ – +true+ if the +data+ Array is presenting the last page. +false+ otherwise
        - +previous_page_number+ – The page number before the current page or +null+ if the current page is the first page.
          May display an out of bounds page number if the current page is also out of bounds.
        - +current_page_number+ – The page number requested by the client, which may or may not be out of bounds
        - +next_page_number+ – The page number after the current page or +null+ if there is no next page
        - +out_of_bounds?+ – +true+ if the requested page number is between 1 and +pages_count+. +false+ otherwise
        - +offset+ – The number of records skipped before the first record in the +data+ Array
      
      === Order
      Sort the resultant records.
      ==== Input Params
      Zero or more of the following, applied in the order they are defined in the request:
      #{columns.map{|column| "- <code>order[#{column}]</code> – \"asc\" to sort column +#{column}+ in ascending order" \
      " or \"desc\" to sort +#{column}+ in descending order"}.join("\n      ")}
      ==== Output Metadata
      - +order+ – Array of sort fields and directions in the order they were received.
        Each Array item contains a Object of:
        - +field+ – The sorted field name
        - +direction+ – Either "asc" or "desc" to mean sorted ascending or sorted descending, respectively
      
      === Search
      Search multiple fields for a partial string and return all results with any matches.
      ==== Input Params
      - <code>search[fields]</code> – A comma-delimited list of fields on which a partial match search will run.
        Possible fields: +#{columns.join('+, +')}+
      - <code>search[query]</code> – A case-insensitive string to match in any part of the fields specified.
        For example, a value of "BROWN" will match "A quick brown fox" if the latter string appears in any of the provided fields
      ==== Output Metadata
      - +search+ – Object containing the following keys:
        - +fields+ – Array of fields queried for partial matches
        - +query+ – Case-insensitive string used to find partial matches in the specified fields

      === Filters
      "Where" filters constrain the results to match all of the specified conditions.
      ==== Input Params
      Zero or more of the following fields as a Hash with operator +OPERATOR+ and value +OPERAND+:
      #{columns.map{|column| "- <code>#{column}[OPERATOR]</code> – Value is +OPERAND+"}.join("\n      ")}
      Any of the above params can be repeated with different <code>OPERATOR</code>s,
      and all provided params are combined to select records that match all of the filter conditions.

      +OPERATOR+ can be one of the following:
      - +eq+ – equals
      - +ne+ – not equals
      - +gt+ – greater than
      - +gte+ – greater than or equals
      - +lt+ – less than
      - +lte+ – less than or equals

      The +OPERATOR+ applies to the +OPERAND+.
      ==== Output Metadata
      - +filters+ – Object of filters and the way they were applied to modify the collection selection:
        - +all+ – Array of filters, all of which were applied to the collection selection.
          Each Array item contains an Object of:
          - +key+ – The field to which this filter applied
          - +operation+ – The operator used in the filter:
            "=" (equals),
            "<>" (not equals),
            ">" (greater than),
            ">=" (greater than or equals),
            "<" (less than), or
            "<=" (less than or equals)
          - +value+ – The operand used in the filter
      DOC

      formats ['JSON']

      example <<-DOC
      # /api/v1/bmc_hosts?page=1&per_page=2&zone_id[gte]=1&zone_id[lte]=3&search[fields]=brand,product&search[query]=R410&order[serial]=asc
      {
          "data": [
              {
                  "id": 5217,
                  "serial": "D4THT42",
                  "ip_address": "192.168.126.40",
                  "power_status": "off",
                  "sync_status": "success",
                  "system_id": null,
                  "created_at": "2010-12-08T10:34:54.000-08:00",
                  "updated_at": "2011-01-25T11:30:29.000-08:00",
                  "zone_id": 3,
                  "error_message": null,
                  "brand": "DELL",
                  "product": "PowerEdge R410",
                  "onboard_status": null,
                  "onboard_step": null,
                  "onboard_error_message": null,
                  "onboard_updated_at": null
              },
              {
                  "id": 5220,
                  "serial": "D4THT48",
                  "ip_address": "192.168.126.47",
                  "power_status": "off",
                  "sync_status": "success",
                  "system_id": null,
                  "created_at": "2010-12-08T10:34:54.000-08:00",
                  "updated_at": "2011-01-25T11:30:30.000-08:00",
                  "zone_id": 3,
                  "error_message": null,
                  "brand": "DELL",
                  "product": "PowerEdge R410",
                  "onboard_status": null,
                  "onboard_step": null,
                  "onboard_error_message": null,
                  "onboard_updated_at": null
              }
          ],
          "pagination": {
              "records_count": 2,
              "pages_count": 1,
              "records_per_page": 2,
              "first_page?": true,
              "last_page?": true,
              "previous_page_number": null,
              "current_page_number": 1,
              "next_page_number": null,
              "out_of_bounds?": false,
              "offset": 0
          },
          "search": {
              "fields": [
                  "brand",
                  "product"
              ],
              "query": "R410"
          },
          "filters": {
              "all": [
                  {
                      "key": "zone_id",
                      "operation": ">=",
                      "value": "1"
                  },
                  {
                      "key": "zone_id",
                      "operation": "<=",
                      "value": "3"
                  }
              ]
          },
          "order": [
              {
                  "field": "serial",
                  "direction": "asc"
              }
          ]
      }
      DOC

      # Pagination
      param :page, Integer, desc: 'Page number, starting from 1'
      param :per_page, Integer, 'Desired maximum number of records per page'

      # Sort
      param :order, Hash, desc: <<-DOC
      One or more of the following keys:

      - +#{columns.join("+\n      - +")}+

      Value of each key must be +asc+ or +desc+, case-insensitive

      Sort order is processed in the order the keys are provided
      DOC

      # Magic Search
      param :search, Hash, desc: 'Search multiple fields for a partial string and return all results with any matches' do
        param :fields, String, desc: <<-DOC
        Comma-delimited list of fields to search.  Example containing all fields:

        <code>#{columns.join(',')}</code>
        DOC
        param :query, String, desc: 'A case-insensitive string to match partially in any of the specified +fields+'
      end

      # Where
      columns = model_class.column_names -
          mock_controller.send(:forbidden_read_columns).map(&:to_s)
      columns.each do |column|
        param column, Hash, desc: <<-DOC
        "Where" filter.
        Key must be +eq+, +ne+, +gt+, +gte+, +lt+, or +lte+.
        Value is the exact operand for the condition. 
        Multiple key-value pairs are allowed and are combined with all other "where" filters.
        DOC
      end
    end
  end
end