export type PlayerProfile = {
	Level: number,
	XP: number,
	MaxXP: number,
	Currency: number, -- CP
	Username: string,
}

export type Challenge = {
	Id: string,
	Title: string,
	Progress: number,
	Goal: number,
	RewardXP: number,
	ExpiresIn: number?, -- Seconds
}

export type LobbyState = {
	PlayerCount: number,
	MaxPlayers: number,
	Status: "Searching" | "Waiting" | "Starting" | "InGame",
	SquadCount: number,
	MaxSquad: number,
}

return {}