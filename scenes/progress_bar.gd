extends ProgressBar

# Themes
var fill_sb : StyleBoxFlat
var bg_sb : StyleBoxFlat

func _ready():
	# Ensure the ProgressBar is initialized before applying changes
	init_bg_box()
	init_fill_box()

func init_fill_box():
	fill_sb = StyleBoxFlat.new()
	fill_sb.corner_radius_top_left = 1
	fill_sb.corner_radius_top_right = 1
	fill_sb.corner_radius_bottom_left = 1
	fill_sb.corner_radius_bottom_right = 1
	add_theme_stylebox_override("fill", fill_sb)
	fill_sb.bg_color = Color.GREEN

func init_bg_box():
	bg_sb = StyleBoxFlat.new()
	bg_sb.corner_radius_top_left = 1
	bg_sb.corner_radius_top_right = 1
	bg_sb.corner_radius_bottom_left = 1
	bg_sb.corner_radius_bottom_right = 1
	add_theme_stylebox_override("background", bg_sb)
	bg_sb.bg_color = Color.WHITE

# Override colors after applying the theme
func update_fill_colour(fg_color: Color):
	fill_sb.bg_color = fg_color
