extends Node2D

var whale_kill_count := 0
@onready var quote_overlay = $"UI/QuoteOverlay"

var quotes = [
	"Delinate chaos bewitched",
	"I came to know of what fine steel the head of a harpoon is made, and how exceedingly sharp the long straight edges are always kept.",
	"The more whales, the less fish",
	"Prepare for what follows",
	"Silently eyeing the vase blue eye of the sea",
	"What could be more full of meaning?",
	"Do you not find a strange analogy to something in yourself?",
	"The mightiest elephant is but a terrier to Leviathan",
	"Man's insanity is heaven's sense",
	"The hideous rot of life should make him easier to harvest",
	"The only whales that thus sank were old, meagre, and broken-hearted creatures",
	"How can'st thou endure without being mad?",
	"I remember the first albatross I ever saw",
	"Yet, this is life",
	"Once more.",
	"Instantaneous, violent, convulsive",
	"Time itself now held long breathes with keen suspense",
	"What then remained?",
	"The whale has no voice",
	
]

func register_whale_kill():
	whale_kill_count += 1
	
	if whale_kill_count == 1 or whale_kill_count % 3 == 0:
		_show_quote_screen()
		
func _show_quote_screen():
	var quote = quotes.pick_random()
	quote_overlay.show_quote(quote)
