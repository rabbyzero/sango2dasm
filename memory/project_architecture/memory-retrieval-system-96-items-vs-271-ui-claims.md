# Memory retrieval system exposes 96 items vs 271 UI claims

- **Category:** project_architecture
- **Memory ID:** c6d69bf8-4afd-40c2-9986-727a62fcba9e
- **Keywords:** SearchMemory, knowledge module, repowiki, retrieval limitation, memory API

## Content

The Sangokushi 2 disassembly project's memory/Knowledge system uses a keyword-based SearchMemory retrieval API that exposes approximately 96 unique memory items through exhaustive keyword sweeps (~30 queries across all categories). Despite the UI's Knowledge panel displaying counts of 271 items (61 development standards + 78 project information + 47 experience lessons + 85 task summaries), the search backend only returns this subset. The remaining ~175 items shown in the UI are likely stored as repowiki knowledge module entries (.qoder/repowiki/) rather than standard memories accessible via SearchMemory. This architectural distinction means not all "Knowledge" items are retrievable through the memory API - some exist only in the knowledge module tree.
