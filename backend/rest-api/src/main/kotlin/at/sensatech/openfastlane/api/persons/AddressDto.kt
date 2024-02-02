package at.sensatech.openfastlane.api.persons

import at.sensatech.openfastlane.domain.models.Address

data class AddressDto(
    val streetNameNumber: String,
    val addressSuffix: String,
    val postalCode: String,

    /**
     * http://data.wien.gv.at/daten/OGDAddressService
     * http://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo?Address=m%C3%BCllnergasse%203
     */
    val addressId: String? = null,
    val gipNameId: String? = null,
)


internal fun Address.toDto() = AddressDto(
    streetNameNumber = this.streetNameNumber,
    addressSuffix = this.addressSuffix,
    postalCode = this.postalCode,
    addressId = this.addressId,
    gipNameId = this.gipNameId,
)
