class StatusChange < ApplicationRecord
  belongs_to :entity, polymorphic: true

  validates_presence_of :status_change_to
  validates_numericality_of :status_change_to, only_integer: true,
                                               greater_than_or_equal_to: 0

  validates_numericality_of :status_change_from, only_integer: true,
                                                 greater_than_or_equal_to: 0,
                                                 allow_nil: true

  def self.update_status_history(entity, to_status)
    # Adds a status change record for the entity.
    # Store prior status as well as new status for reporting purposes.

    # Returns a collection proxy for the status_changes if successful.
    # Returns false if not successful.

    if entity.status_changes.empty?
      prior_status = nil
    else
      prior_status = entity.status_changes.last.status_change_to
    end

    entity.status_changes << StatusChange
                             .create(status_change_from: prior_status,
                                     status_change_to: entity.class.statuses[to_status])
  end

  def self.status_change_time(entity, to_status, which = :latest)
    # Returns time(s) when entity transitioned to specific status.
    # If 'which' == :latest, returns latest time that entity status == to_status
    # If 'which' == :all, returns an array of times that entity status
    #             == to_status (in ascending order)
    # Returns nil if to_status is not found
    # Raises exception if 'which' is invalid

    change_times = entity.status_changes
                         .where(status_change_to: entity.class.statuses[to_status])
                         .order(:created_at).pluck(:created_at)

    return change_times.last if which == :latest
    return change_times      if which == :all

    raise ArgumentError.new("Invalid 'which' argument")
  end
end
