package at.sensatech.openfastlane.api

import org.springframework.security.access.prepost.PreAuthorize


@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
@PreAuthorize("isAnonymous()")
annotation class RestrictIsAnonymous

// User Roles for ADMIN and MANAGER
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
@PreAuthorize("hasAnyRole('OFL_SUPERUSER')")
annotation class RequiresSuperuser

@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
@PreAuthorize("hasAnyRole('OFL_SUPERUSER','OFL_ADMIN')")
annotation class RequiresAdmin

@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
@PreAuthorize("hasAnyRole('OFL_SUPERUSER','OFL_ADMIN','OFL_MANAGER')")
annotation class RequiresManager

@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
@PreAuthorize("hasAnyRole('OFL_SUPERUSER','OFL_ADMIN','OFL_MANAGER','OFL_READER')")
annotation class RequiresReader
