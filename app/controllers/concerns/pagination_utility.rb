module PaginationUtility
  extend ActiveSupport::Concern

  # This constant is used to specify "all" items to be shown in a view that
  # uses the will_paginate gem for listing a collection.  That has to be a number.
  # This particular number is used when the user selects "All" in the
  # items-per-page selection.
  ALL_ITEMS = 10_000

  DEFAULT_ITEMS_SELECTION = 10.freeze # Default items-per-page setting

  def process_pagination_params(entity)
    # This method is used in controller actions involved in pagination of
    # collection tables (e.g., companies, jobs, etc.).

    # It is passed a string that indicates the type of paginated collection,
    #  e.g. "company", "job".  That string must be unique across all
    #  paginated collections, since it is used as a key to store data
    #  in the session store.

    # Since this method operates in the context of a controller action, it
    #  has access to the 'params' hash.

    # It returns:
    #  1) search params hash, for use with ransack gem's "ransack" method,
    #  2) the user's last items-per-page selection (an integer or 'All'),
    #  3) the actual number of items-per-page to show in the table.

    # This method uses the session to store (and recover) search criteria
    # and per-page items selection.  These are persisted across action
    # invocations.

    entity_items_selection = (entity + '_items_selection').to_sym
    entity_search_criteria = (entity + '_search_criteria').to_sym

    if params[:items_count] # << user has selected a per-page items count
      items_count = params[:items_count]
      items_selection = items_count == 'All' ? 'All' : items_count.to_i

      session[entity_items_selection] = items_selection

      search_criteria = JSON.parse(session[entity_search_criteria],
                                   quirks_mode: true)

      search_params = search_criteria ?
        ActionController::Parameters.new(search_criteria) : nil

      # Reset params hash so that sort_link works correctly in the view
      # (the sort links are built using, as one input, the controller params)
      params[:q] = search_params
      params.delete(:items_count)

    else
      items_selection = DEFAULT_ITEMS_SELECTION
      if session[entity_items_selection]
        items_selection = session[entity_items_selection]
      end

      session[entity_search_criteria] = params[:q].to_json

      search_params = params[:q]
    end

    items_per_page = items_selection == 'All' ? ALL_ITEMS : items_selection

    [search_params, items_selection, items_per_page]
  end
end
