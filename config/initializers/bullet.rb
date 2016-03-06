if defined? Bullet
  Bullet.enable = true
  Bullet.alert = true
  Bullet.add_whitelist type: :unused_eager_loading,
                 class_name: 'Agency',
                association: :companies
  Bullet.add_whitelist type: :unused_eager_loading,
                 class_name: 'Company',
                association: :addresses
end
