package at.sensatech.openfastlane.domain

import at.sensatech.openfastlane.domain.models.ModelsClasses
import at.sensatech.openfastlane.domain.repositories.RepositoriesClasses
import org.springframework.boot.autoconfigure.domain.EntityScan
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder

@EntityScan(basePackageClasses = [ModelsClasses::class])
@EnableMongoRepositories(basePackageClasses = [RepositoriesClasses::class])
@Configuration
class DomainModule {
    @Bean
    fun passwordEncoder(): PasswordEncoder {
        return BCryptPasswordEncoder()
    }
}
