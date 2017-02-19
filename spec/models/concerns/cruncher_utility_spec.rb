require 'rails_helper'
class UtilityTester
  include CruncherUtility
end

RSpec.describe CruncherUtility do
  let(:job_results) do
    { 'matcher1' => [{ 'jobId' => '3', 'stars' => 3.3 },
                     { 'jobId' => '2', 'stars' => 2.2 },
                     { 'jobId' => '1', 'stars' => 1.0 }],
      'matcher2' => [{ 'jobId' => '4', 'stars' => 4.4 },
                     { 'jobId' => '3', 'stars' => 3.8 },
                     { 'jobId' => '2', 'stars' => 5.0 }] }
  end

  let(:resume_results) do
    { 'matcher1' => [{ 'resumeId' => '2', 'stars' => 2.0 },
                     { 'resumeId' => '7', 'stars' => 4.9 },
                     { 'resumeId' => '5', 'stars' => 3.6 }],
      'matcher2' => [{ 'resumeId' => '8', 'stars' => 1.8 },
                     { 'resumeId' => '5', 'stars' => 3.4 },
                     { 'resumeId' => '7', 'stars' => 1.7 }] }
  end

  it 'processes job match results' do
    processed_results = UtilityTester.process_match_results(job_results, 'jobId')
    expect(processed_results.length).to be 4
    expect(processed_results)
      .to eq [[2, 5.0], [4, 4.4], [3, 3.8], [1, 1.0]]
  end

  it 'processes resume match results' do
    processed_results = UtilityTester.process_match_results(resume_results, 'resumeId')
    expect(processed_results.length).to be 4
    expect(processed_results)
      .to eq [[7, 4.9], [5, 3.6], [2, 2.0], [8, 1.8]]
  end

  it 'sorts match results based on score' do
    match_results =  [{ message: 'No resume on file', job_seeker_name: 'McCaffrey, Mary' },
                      { status: 'SUCCESS', score: 2.0, job_seeker_name: 'Joseph, John' },
                      { status: 'ERROR', message: 'Could not connect to cruncher',
                        job_seeker_name: 'Jobs, Steve' },
                      { status: 'SUCCESS', score: 4.0, job_seeker_name: 'Doe, John' }]
    output_results = [{ status: 'SUCCESS', score: 4.0, job_seeker_name: 'Doe, John' },
                      { status: 'SUCCESS', score: 2.0, job_seeker_name: 'Joseph, John' },
                      { status: 'ERROR', message: 'Could not connect to cruncher',
                        job_seeker_name: 'Jobs, Steve' },
                      { message: 'No resume on file', job_seeker_name: 'McCaffrey, Mary' }]

    expect(ResumeCruncher.sort_by_score(match_results)).to eq output_results
  end
end
