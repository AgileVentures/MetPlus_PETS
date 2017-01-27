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
          object_id = match_item[key_id].to_i

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

      match_set.sort { |a, b| b[1] <=> a[1] }
    end

    # Sorts the match_results hash based on `score`, in descending order,
    # placing nil scores at the end
    # Example input:
    # [ { message: 'No resume on file', job_seeker_name: 'McCaffrey, Mary' },
    #   { status: 'SUCCESS', score: 2.0, job_seeker_name: 'Joseph, John' },
    #   { status: 'ERROR', message: 'Could not connect to cruncher',
    #       job_seeker_name: 'Jobs, Steve' },
    #   { status: 'SUCCESS', score: 4.0, job_seeker_name: 'Doe, John' },
    # ]
    # Example output:
    # [ { status: 'SUCCESS', score: 4.0, job_seeker_name: 'Doe, John' },
    #   { status: 'SUCCESS', score: 2.0, job_seeker_name: 'Joseph, John' },
    #   { status: 'ERROR', message: 'Could not connect to cruncher',
    #       job_seeker_name: 'Jobs, Steve' },
    #   { message: 'No resume on file', job_seeker_name: 'McCaffrey, Mary' },
    # ]
    def sort_by_score(match_results)
      match_results.sort do |a, b|
        # if both values are non-nil, reverse the order
        if a[:score] && b[:score]
          b[:score] <=> a[:score]
        else
          # if a[:score] is non-nil, it should appear before b[:score]
          a[:score] ? -1 : 1
        end
      end
    end
  end
end
