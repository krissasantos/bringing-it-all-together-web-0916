class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil,name:,breed:)
    @id = id
    @name = name
    @breed = breed
  end


  def self.create_table
    sql=<<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end



  def self.drop_table
    sql=<<-SQL
     DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  # def self.create(name:, breed:) #this method is for something that ISNT in DB yet.That's why you save.
  #   dog = Dog.new(name,breed)
  #   dog.save
  #   dog
 
  # end

  def self.create(hash)
    new_dog = Dog.new(hash).save
  end


def self.new_from_db(row) #used for finding something in DB and returning an instance. 

  new_dog = Dog.new(id: row[0] , name: row[1],  breed: row[2] )
  new_dog.id = row[0]
  new_dog.name = row[1]
  new_dog.breed = row[2]
  new_dog

end


  def self.find_by_id(id)
    sql =<<-SQL
      SELECT * from dogs 
      WHERE id = ?
      LIMIT 1
    SQL
        DB[:conn].execute(sql,id).map do |row| #this is where your self.new_from_db gets used
          self.new_from_db(row)
        end.first #why dot first again??? if youll be returing the instance anyway? what's instance.first?
  end


  def self.find_by_name(name)
    sql =<<-SQL
      SELECT * from dogs 
      WHERE name = ?
      LIMIT 1
    SQL
        DB[:conn].execute(sql,name).map do |row| #this is where your self.new_from_db gets used
          self.new_from_db(row)
        end.first #why dot first again??? if youll be returing the instance anyway? what's instance.first?
  end




  def self.find_or_create_by(name:, breed:)

    dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed) #new format 
   
    # dogs =<<-SQL
    #   SELECT * FROM dogs 
    #   WHERE name = ? AND breed = ?
    # SQL
    # DB[:conn].execute(dogs,name,breed)

    if dogs.empty?
      new_dog = self.create(name: name, breed: breed) #when do you save it to a new id? once you find_or_create?
    else
      new_dog = self.new_from_db(dogs[0])
    end
     new_dog
  end

  def save
    if self.id
      self.update
    else
      sql=<<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
      self
  end


  def update

   sql =<<-SQL "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
   SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
 


end