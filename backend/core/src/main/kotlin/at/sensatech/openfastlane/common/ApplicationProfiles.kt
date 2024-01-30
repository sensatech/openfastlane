package at.sensatech.openfastlane.common

import org.bson.types.ObjectId

object ApplicationProfiles {
    const val TEST = "test"
    const val NOT_TEST = "!test"
    const val INTEGRATION_TEST = "integration-test"
    const val DOCKER = "docker"
}

fun newId() = ObjectId.get().toString()