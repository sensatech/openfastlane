package at.sensatech.openfastlane.domain.models

data class Address(
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