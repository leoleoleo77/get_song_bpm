package com.leoleoleo.getsongbpm

object DebugLog {
    fun info(message: Any?, tag: String?) =
        println("${tag ?: ""} [ANDROID] $message")

    fun getString(message: Any?, tag: String?) =
        "${tag ?: ""} [ANDROID] $message"
}