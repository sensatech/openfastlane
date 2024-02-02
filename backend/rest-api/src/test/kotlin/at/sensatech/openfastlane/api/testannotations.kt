package at.sensatech.openfastlane.api

import org.junit.jupiter.api.Test
import org.springframework.security.test.context.support.TestExecutionEvent
import org.springframework.security.test.context.support.WithAnonymousUser
import org.springframework.security.test.context.support.WithUserDetails

@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
@WithUserDetails("superuser", setupBefore = TestExecutionEvent.TEST_EXECUTION)
@Test
annotation class TestAsSuperuser

@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
@WithUserDetails("admin", setupBefore = TestExecutionEvent.TEST_EXECUTION)
@Test
annotation class TestAsAdmin

@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
@WithUserDetails("manager", setupBefore = TestExecutionEvent.TEST_EXECUTION)
@Test
annotation class TestAsManager

@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
@WithUserDetails("reader", setupBefore = TestExecutionEvent.TEST_EXECUTION)
@Test
annotation class TestAsReader

@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
@WithAnonymousUser
@Test
annotation class TestAsAnonymousUser
