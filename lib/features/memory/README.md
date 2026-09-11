# Memory

Sprint 5 adds the persistent JARVIS Memory Engine. Long-term memory is stored in the dedicated Hive `memories` box through the flow `UI → MemoryController → MemoryRepository → MemoryService → Hive`.

Chat history remains separate from long-term memory. Only explicit memory commands or manually added memory cards are stored, and sensitive credentials are rejected before persistence.
