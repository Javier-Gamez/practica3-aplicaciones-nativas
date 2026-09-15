package mx.ipn.escom.camaramic

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

/**
 * Swift can't subscribe to a Kotlin `StateFlow` directly (no Combine
 * bridge without an extra library), so this exposes a plain callback API
 * instead -- call `watch(flow) { value -> ... }` from SwiftUI, e.g. inside
 * `.onAppear` / a `@StateObject` wrapper, and `cancel()` in `.onDisappear`.
 */
class FlowWatcher {
    private val scope = MainScope()

    fun <T> watch(flow: StateFlow<T>, onEach: (T) -> Unit) {
        scope.launch(Dispatchers.Main) {
            flow.collect { onEach(it) }
        }
    }

    fun cancel() {
        scope.cancel()
    }
}
