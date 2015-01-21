require 'json'
require 'digest/md5'

class User
  @id
  #@friends = []
  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :email
  attr_accessor :age
  attr_accessor :gender
  attr_accessor :password
  attr_accessor :telephone
  attr_accessor :interests
  attr_accessor :friends

  # attr_acessor is translated to:
  # def age=(value)
  #   @age = value
  # end
  #
  # def age
  #   @age
  # end

  private
    def set_md5_id
      if @id.nil?
        @id = Digest::MD5.hexdigest(@email)
      end
    end

    # Pega todos os amigos e tira a lista de amigos dos seus amigos
    def convert_friends( friends_list )
      json_friends_list = []
      if !friends_list.nil?
        friends_list.each do |index|
          if index.instance_of?(User)
            index.friends = []
            json_friends_list << ( index.user_to_json )
          else
            # puts index['friends']
            index.friends = [index]
            json_friends_list = ( User.new.from_json_data(index) )
          end
        end
      end
      return json_friends_list
    end

  public
    def initialize(n = nil, l = nil, e = nil, a = nil, g = nil, p = nil, t = nil, i = nil, f = nil)
      if !n.nil? && !l.nil? && !e.nil? && !a.nil? && !g.nil? && !p.nil? && !t.nil? && !i.nil?
        @first_name= n
        @last_name = l
        @email = e
        @age = a
        @gender = g
        @password = p
        @telephone = t
        @interests = i
        @friends = f.nil? ? [] : f
        set_md5_id
      end
    end

    # Transforma o objeto em json
    # Quando precisar enviar para um usuário
    def user_to_json
      return {
        'id' => @id,
        'first_name' => @first_name,
        'last_name' => @last_name,
        'email' => @email,
        'age' => @age,
        'gender' => @gender,
        'password' => @password,
        'telephone' => @telephone,
        'interests' => @interests,
        'friends' => convert_friends(@friends)
      }
    end

    #O http_get usa este método,
    def from_json_file(fileUrl)
      data = JSON.parse(  File.read("#{fileUrl.chars.first}/#{fileUrl}.json") )
      @first_name = data['first_name']
      @last_name = data['last_name']
      @email = data['email']
      @age = data['age']
      @gender = data['gender']
      @password = data['password']
      @telephone = data['telephone']
      @interests = data['interests']
      @friends = convert_friends(data['friends'])
      @id = data['id'].nil? ? set_md5_id : data['id']
    end

    #Recebe um json e transforma em usuario
    def from_json_data(data)
      @first_name = data['first_name']
      @last_name = data['last_name']
      @email = data['email']
      @age = data['age']
      @gender = data['gender']
      @password = data['password']
      @telephone = data['telephone']
      @interests = data['interests']
      @friends = convert_friends(data['friends'])
      @id = data['id'].nil? ? set_md5_id : data['id']
    end

    # Escrever
    def save_user_on_file
      begin
        folder = @id.chars.first
        if !Dir.exist?(folder)
          Dir.mkdir(@id.chars.first)
        end
        file = File.open("#{folder}/#{@id}.json", 'w+')
        file.write(user_to_json.to_json)
      rescue IOError => e
        throw e
      ensure
        file.close unless file == nil
      end
    end

    def get_user_on_file (md5_email)
      # begin
      folder = md5_email.chars.first
      file = File.read("#{folder}/#{md5_email}.json")
      from_json_data( JSON.parse( file ) )
      return
      # rescue IOError => e
      #   throw e
      # ensure
      #   file.close unless file == nil
      # end
    end
end