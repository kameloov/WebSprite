tool
extends Sprite

enum ImageType {PNG,JPG,AUTO_DETECT}
enum LoadStrategy {DISK_FIRST,REMOTE_FIRST}

export (ImageType) var type = ImageType.AUTO_DETECT;
export (LoadStrategy) var loadPriority = LoadStrategy.DISK_FIRST;
export var autoLoad = false;
export var url = "";

var cache_folder = "user://websprite/";
onready var http  = HTTPRequest.new();
func _ready():
	add_child(http);
	http.connect("request_completed",self,"_completed");
	if autoLoad:
		loadTexture();
	
func loadTexture(url =""):
	if url != "":
		self.url = url;
	if loadPriority == LoadStrategy.DISK_FIRST : 
		load_from_disk();
	elif loadPriority == LoadStrategy.REMOTE_FIRST : 
		load_from_url();

func load_from_url():
	if url=="":
		printerr("url is not valid : %s"%self.url);
	else :
		http.request(url);
		
func load_from_disk():
	var paths = [];
	if type == ImageType.AUTO_DETECT:
		var basename =cache_folder+ generate_file_name();
		paths.append(basename+'png')
		paths.append(basename+'jpg')
		paths.append(basename+'jpeg')
		paths.append(basename+'bmp')
	else :
		paths.append(cache_folder+generate_file_name());
	var img = Image.new();
	var loaded = null; 
	for path in paths:
		loaded = img.load(path);
		if loaded == OK: 
			var tex = ImageTexture.new();
			tex.create_from_image(img);
			texture = tex; 
			break;
			
	if loaded != OK :
		match loadPriority:
			LoadStrategy.DISK_FIRST : load_from_url();
			LoadStrategy.REMOTE_FIRST : printerr("error couldn't load texture from any source");
	
func _completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		var extention = "";
		for h in headers:
			if h.to_lower().begins_with("content-type"):
				extention = find_extention(h);
		save_image(body,extention);
		load_from_disk();
	else :
		match loadPriority:
			LoadStrategy.REMOTE_FIRST : load_from_disk();
			LoadStrategy.DISK_FIRST : printerr("error couldn't load texture from any source"); 


func check_dir():
	var dir = Directory.new();
	if not dir.dir_exists(cache_folder):
		dir.make_dir(cache_folder);
	
func save_image(data,extention =""):
	check_dir();
	var file = File.new();
	var path = cache_folder+generate_file_name(extention);
	file.open(path, File.WRITE);
	file.store_buffer(data);
	file.close();

func find_extention(source:String):
	var s = source.split(":")[1].strip_edges();
	return s.trim_prefix("image/");
	
func generate_file_name(extention=""):
	var fname = url.sha1_text();
	match type :
		ImageType.PNG : fname +=".png";
		ImageType.JPG : fname +=".jpg"
		ImageType.AUTO_DETECT : fname += '.'+extention;
	return fname;
		
		
		
		
