require 'net/http'
require 'net/https'
require 'uri'
require 'json'


class BigFiveTextConverter
  @text = nil

  def initialize(text)
    @text = text 
  end

  def to_h
    @hsh = {"NAME": "Michael Blake"}
    categories = ["EXTRAVERSION", "AGREEABLENESS", "CONSCIENTIOUSNESS", "NEUROTICISM", "OPENNESS TO EXPERIENCE"]
    categories.each do |category|
      @hsh[category] = {}
      match_field(category)
      @hsh[category]["Overall Score"] = match_field(category)
    end 
    subcats = {
      "EXTRAVERSION": ["Friendliness", "Gregariousness", "Assertiveness", "Activity Level", "Excitement-Seeking", "Cheerfulness"],
      "AGREEABLENESS": ["Trust", "Morality", "Altruism", "Cooperation", "Modesty", "Sympathy"],
      "CONSCIENTIOUSNESS": ["Self-Efficacy", "Orderliness", "Dutifulness", "Achievement-Striving", "Self-Discipline", "Cautiousness"],
      "NEUROTICISM": ["Anxiety", "Anger", "Depression", "Self-Consciousness", "Immoderation", "Vulnerability"],
      "OPENNESS TO EXPERIENCE": ["Imagination", "Artistic Interests", "Emotionality", "Adventurousness", "Intellect", "Liberalism"]
    }
    subcats.each_key do |cat|
      @hsh[cat.to_s]["Facets"] = {}
      subcats[cat].each do |subcat|
        cat = cat.to_s
        @hsh[cat]["Facets"][subcat] = match_field(subcat)
      end
    end
    @hsh
  end

  private 

  def match_field(category)
    result = @text.match(/#{category}.+[0-9]+/).to_s.match(/[0-9]+/).to_s
    result
  end
end

class BigFiveResultsPoster
  @token = nil 
  @code = nil
  def initialize(results_hash, email)
    @hsh = results_hash 
    @hsh["EMAIL"] = email
  end

  def token
    @token
  end 

  def code
    @code
  end

  def post
    uri = URI.parse("https://recruitbot.trikeapps.com/api/v1/roles/senior-team-lead/big_five_profile_submissions")

    header = {'Content-Type': 'text/json'}

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = @hsh.to_json

    response = http.request(request)
    @token = response.body
    @code = response.code
    response.code == "422" ? false : true
  end 
end

def submit_results
  file = File.open('./results.txt', "r")
  data = file.read
  file.close

  converter = BigFiveTextConverter.new(data)
  bfrp = BigFiveResultsPoster.new(converter.to_h, "mblakedevelopment@gmail.com")
  return bfrp.post, bfrp
end