if defined? Bullet
  Bullet.enable = true
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
end
