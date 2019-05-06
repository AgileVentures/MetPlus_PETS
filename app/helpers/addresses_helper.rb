module AddressesHelper
  def address_has_data?(address)
    address.street? || address.city? || address.state? || address.zipcode?
  end

  def address_subform_visibility(address)
    return 'hidden' unless address_has_data?(address)

    nil
  end

  def address_subform_toggle_text(address)
    address_has_data?(address) ? 'Cancel new location' : 'Create new location'
  end
end
