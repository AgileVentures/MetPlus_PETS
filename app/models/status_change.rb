class StatusChange < ActiveRecord::Base
  belongs_to :entity, polymorphic: true

  validates_presence_of :status_change_to
  validates_numericality_of :status_change_to, only_integer: true,
                            greater_than_or_equal_to: 0

  validates_numericality_of :status_change_from, only_integer: true,
                            greater_than_or_equal_to: 0,
                            allow_nil: true

  def self.update_status_history(entity, from_status, to_status)
    # Adds a status change record for the entity.
    # Returns a collection proxy for the status_changes if successful.
    # Returns false if not successful.

    entity.status_changes << StatusChange.
              create(status_change_from: entity.class.statuses[from_status],
                     status_change_to: entity.class.statuses[to_status])
  end

  def self.status_change_time(entity, to_status)
    # Returns time when entity transitioned to specific status.
    # Returns nil if to_status is not found.
    # NOTE: this assumes that an entity assume the specified status
    #       only once in its life cycle.  If this changes, this code
    #       must be changed as well.

    change = entity.status_changes.
        where(status_change_to: entity.class.statuses[to_status])[0]
    return change.created_at if change
    nil
  end
end
