if defined? Bullet
  Bullet.enable = false
  Bullet.alert = true
  Bullet.add_whitelist type: :unused_eager_loading,
                 class_name: 'Agency',
                association: :companies
  Bullet.add_whitelist type: :unused_eager_loading,
                 class_name: 'Company',
                association: :addresses
  Bullet.add_whitelist type: :unused_eager_loading,
                 class_name: 'AgencyPerson',
                association: :user
  Bullet.add_whitelist type: :unused_eager_loading,
                 class_name: 'Job',
                association: :skills
  Bullet.add_whitelist type: :unused_eager_loading,
                 class_name: 'JobSeeker',
                association: :user
  Bullet.add_whitelist type: :unused_eager_loading,
                 class_name: 'JobSeeker',
                association: :job_seeker_status
  Bullet.add_whitelist type: :unused_eager_loading,
                 class_name: 'JobSeeker',
                association: :job_applications
end
