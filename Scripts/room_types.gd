extends Node2D

enum RoomType {
	FILLER,       # 0 - Random filler room
	HORIZONTAL,   # 1 - Has left and right exits
	LRB,          # 2 - Left, right, bottom exits
	LRT,          # 3 - Left, right, top exits
	VERTICAL,     # 4 - Top and bottom exits (optional, depending on design)
	ARENA         # 5 - Special "combat" room (optional)
}
