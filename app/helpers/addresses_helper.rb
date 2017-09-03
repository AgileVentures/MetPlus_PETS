module AddressesHelper

  def address_has_data?(address)
    address.street? || address.city? || address.state? || address.zipcode?
  end
end
