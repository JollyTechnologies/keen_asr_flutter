package com.keenresearch.keenasr.flutter.util

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext


fun <T> CoroutineScope.launchPigeon(
    callback: (Result<T>) -> Unit,
    context: CoroutineContext = EmptyCoroutineContext,
    block: suspend () -> T
): Unit {
    launch(context) { callback(runCatching { block() }) }
}