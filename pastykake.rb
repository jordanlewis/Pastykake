require 'sinatra'
require 'erb'

helpers do
	def random_string(length)
		(0..length).map{(97+rand(25)).chr}.join
	end
	def dropdown_options(selected)
		filetype_map = {"bash" => "Bash", "css" => "CSS", "diff" => "Diff", "js" => "Javascript",
						"php" => "PHP", "plain" => "Plaintext", "py" => "Python", "ruby" => "Ruby",
						"sql" => "SQL", "html" => "HTML/XML"}

		filetype_map.sort.collect do |k,v|
			sel_str = selected == k ? "selected " : ""
			"<option #{sel_str}value=\"#{k}\">#{v}</option>"
		end .join("\n")
	end

	def pastebox
		erb :pastebox
	end
end

get '/' do
	erb :index
end

post '/make_paste' do
	begin
		filename = random_string(4)
	end while File.exists?("pastes/#{filename}")
	File.open("pastes/#{filename}", 'w') {|f| f.write(request["filetype"] + "\n" + request["new_paste"])}
	redirect to("/#{filename}")
end

get '/:name' do
	@paste_text = ""
	if File.exists?("pastes/#{params[:name]}")
		@filetype, newline, @paste_text = IO.read("pastes/#{params[:name]}").partition("\n")
		@selected = @filetype

		if request["dl"] and request["dl"] == "1":
			filetype_extension_map = {"bash" => :sh, "css" => :css, "diff" => :diff, "js" => :js,
									  "php" => :php, "plain" => :txt, "py" => :py, "ruby" => :rb,
									  "sql" => :sql, "html" => :html}
			ext = filetype_extension_map[@filetype]
			content_type ext
			[200, {"Content-Disposition" => "attachment; filename=#{params[:name]}.#{ext}"}, @paste_text]
		else
			erb :paste
		end
	else
		redirect to('/')
	end
end

