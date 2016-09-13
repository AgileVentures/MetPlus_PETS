module CruncherUtility
  extend ActiveSupport::Concern

  module ClassMethods
    def process_match_results(results)
      match_set = {}

      # First level of results is a hash of specific matcher results ....
      results.each_value do |matcher|
        # Second level is array of object id and matching scores (hashes) ....
        matcher.each do |match_item|
          object_id = (match_item.has_key?('resumeId') ?
                       match_item['resumeId'] : match_item['jobId']).to_i

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
