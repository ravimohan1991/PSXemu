#pragma once
#include <cstdint>

using byte = std::int8_t;

/**
 * @brief
 * one unsigned byte
 */
using ubyte = std::uint8_t;
using ushort = std::uint16_t;

/**
 * @brief
 * Four bytes, unsigned. For storing 32bit PS1
 * instructions and Program Counter.
 */
using uint = std::uint32_t;
using ulong = std::uint64_t;
