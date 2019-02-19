module Jobs
  class SynchronizeCruncher
    attr_accessor :job_query, :job_cruncher
    def initialize(job_query = nil, job_cruncher = nil)
      @job_query = job_query || Jobs::Query.new
      @job_cruncher = job_cruncher || JobCruncher
    end

    def call
      job_query.all.each do |job|
        next if job_cruncher.update_job(job.id, job.title, job.description)

        job_cruncher.create_job(job.id, job.title, job.description)
      end
    end
  end
end
