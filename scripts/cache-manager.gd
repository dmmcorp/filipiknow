extends Node

const CACHE_PATH := "user://cache/chapters/"
const ASSET_PATH := "user://cache/assets/"

@onready var http := HTTPRequest.new()

func _ready() -> void:
	add_child(http)
	DirAccess.make_dir_recursive_absolute(CACHE_PATH)
	DirAccess.make_dir_recursive_absolute(ASSET_PATH)


# --- Main loader ---
func load_chapter(selected_novel: String, selected_chapter: int) -> Dictionary:
	var chapter = str(selected_chapter)
	var cache_file = CACHE_PATH + selected_novel + "-" + chapter + ".json"

	var new_data := await fetch_chapter_from_convex(selected_novel, selected_chapter)

	if new_data:
		save_chapter(selected_novel, chapter, new_data)
		return new_data

	return {}


# --- Save chapter locally ---
func save_chapter(selected_novel: String, selected_chapter: String, data: Dictionary) -> void:
	var path := CACHE_PATH + selected_novel + "-" + selected_chapter + ".json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		print("💾 Cached chapter %s" % selected_novel % "-" % selected_chapter)


# --- Fetch chapter from Convex (HTTP Action) ---
func fetch_chapter_from_convex(selected_novel: String, selected_chapter: int, transition: bool = true) -> Dictionary:
	var url := Globals.url + "getChapterDialogues"
	var chapter := str(selected_chapter)
	var cache_file := CACHE_PATH + selected_novel + "-" + chapter + ".json"
	# --- Try to read local cache to get updatedAt ---
	var cached_updated_at := ""
	var cached_data: Dictionary
	
	if FileAccess.file_exists(cache_file):
		var cached_text := FileAccess.get_file_as_string(cache_file)
		var cached_json = JSON.parse_string(cached_text)
		if cached_json:
			cached_data = cached_json
			cached_updated_at = cached_data.result.get("novel_metadata", {}).get("updatedAt", "")

	var data := {
		"novel": selected_novel,
		"chapter": selected_chapter,
		"teacherId": Globals.progress_data.student.teacher["teacherId"],
		"sectionId": Globals.progress_data.student.teacher["sectionId"],
		"cached_updatedAt": cached_updated_at
	}
	var headers := ["Content-Type: application/json"]
	var json_data := JSON.stringify(data)

	# --- Start HTTP Request ---
	var err := http.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if err != OK:
		push_warning("❌ HTTP request failed to start: %s" % err)
		return {}

	var result = await http.request_completed
	var response_code: int = result[1]
	var response_body: PackedByteArray = result[3]

	# --- Handle 404: Chapter deleted ---
	if response_code == 404:
		print("⚠️ Chapter deleted on server, removing local cache.")
		if FileAccess.file_exists(cache_file):
			DirAccess.remove_absolute(cache_file)
		return {}

	# --- Handle other HTTP errors ---
	if response_code != 200:
		push_warning("⚠️ Convex responded with %s" % response_code)
		return {}

	# --- Parse JSON response ---
	var text := response_body.get_string_from_utf8()
	var json_result = JSON.parse_string(text)
	var response = json_result
	
	if not response.get("success", false):
		push_warning("⚠️ Convex returned an error: %s" % response.get("error", "Unknown"))
		return {}
	
	# --- If server says no updates, use cache ---
	if response.has("message") and response.message == "No updates available":
		print("✅ No updates available — using local cache.")
		Globals.chapter_resource = cached_data
		if transition:
			transition_to_chapter()
		return cached_data

	print("⚠️ No cache found, but server says no updates. Returning empty.")

	# --- Extract new chapter data ---
	var new_data: Dictionary = response
	var remote_updated_at: String = new_data.result.novel_metadata.get("updatedAt", "")
	var should_update_cache := true

	# --- Check if local cache exists ---
	if cached_updated_at:
		print("eto ang nafetch:",remote_updated_at)
		print("eto ang local:",cached_updated_at)
		if remote_updated_at == cached_updated_at:
			print("✅ Cache is up-to-date. No need to re-save.")
			Globals.chapter_resource = cached_data
			print(Globals.chapter_resource.result)
			if transition:
				transition_to_chapter()
			return cached_data
		else:
			print("🔄 Remote chapter is newer, updating cache.")
	else:
		print("📥 No cache found, saving new chapter data.")

	# --- Save new data to cache ---
	var file := FileAccess.open(cache_file, FileAccess.WRITE)
	file.store_string(JSON.stringify(new_data))
	file.close()

	Globals.chapter_resource = new_data

	if transition:
		transition_to_chapter()
	return new_data

func transition_to_chapter() -> void:
	var story_scene = load("res://scenes/main/story.tscn")
	var chapter_title = Globals.chapter_resource.result.novel_metadata.chapter_title
	var chapter_number = Globals.chapter_resource.result.novel_metadata.chapter
	SceneTransition.set_chapter_info(chapter_number, chapter_title)
	Globals.access_grid_buttons()
	SceneTransition.transition_chapter("res://scenes/main/chapter.tscn")
	
# --- Cached Image Loader ---
func get_cached_image(url: String) -> ImageTexture:
	# Create cache filename based on URL hash (avoids illegal characters)
	var hash := str(url.hash())
	var local_path := ASSET_PATH + hash + ".png"

	# ✅ If cached file exists, load from disk
	if FileAccess.file_exists(local_path):
		var img := Image.new()
		var err := img.load(local_path)
		if err == OK:
			var tex := ImageTexture.create_from_image(img)
			return tex

	# ⬇️ Otherwise, download and cache it
	print("⬇️ Downloading and caching image:", url)
	var req := HTTPRequest.new()
	add_child(req)
	var http_err := req.request(url)
	if http_err != OK:
		push_warning("❌ Failed to start image download: %s" % http_err)
		return null

	var result = await req.request_completed
	var response_code: int = result[1]
	var response_body: PackedByteArray = result[3]

	if response_code == 200:
		# Save to cache
		var file := FileAccess.open(local_path, FileAccess.WRITE)
		file.store_buffer(response_body)
		file.close()

		# Convert to texture
		var img := Image.new()
		var img_err := img.load(local_path)
		if img_err == OK:
			var tex := ImageTexture.create_from_image(img)
			return tex
	else:
		push_warning("⚠️ Image HTTP error: %s" % response_code)

	return null
	
func clear_cache() -> void:
	var dir := DirAccess.open(CACHE_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var full_path := CACHE_PATH + file_name
				var err := DirAccess.remove_absolute(full_path)
				if err == OK:
					print("🗑️ Deleted:", file_name)
				else:
					print("⚠️ Failed to delete:", file_name, "Error code:", err)
			file_name = dir.get_next()
		dir.list_dir_end()
		print("✅ Cache cleared successfully.")
	else:
		print("❌ Failed to open cache directory.")
