extends Node

class_name ImageLoader

# Call this to load an image from a URL
# ImageLoader.gd

func load_image_async(url: String) -> ImageTexture:
	var http := HTTPRequest.new()
	add_child(http)

	var error = http.request(url)
	if error != OK:
		push_error("Request failed")
		return null
	var result = await http.request_completed

	var image = Image.new()
	var load_err = image.load_png_from_buffer(result[3])
	if load_err != OK:
		push_error("Couldn't load image from buffer.")
		return null

	var texture = ImageTexture.create_from_image(image)
	http.queue_free()
	return texture
