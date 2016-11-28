module CruncherUtility
  extend ActiveSupport::Concern

  module ClassMethods
    def process_match_results(results, key_id)
      match_set = {}
      return match_set if results.nil?

      # First level of results is a hash of specific matcher results ....
      results.each_value do |matcher|
        # Second level is array of object id and matching scores (hashes) ....
        matcher.each do |match_item|
          object_id =  match_item[key_id].to_i

          # Have we seen this object from another matcher?
          # If so, use highest score
          if match_set[object_id]
            match_set[object_id] = match_item['stars'] if
            match_set[object_id] < match_item['stars']
          else
            match_set[object_id] = match_item['stars']
          end
        end
      end

      match_set.sort {|a,b| b[1] <=> a[1]}
    end
  end
end
