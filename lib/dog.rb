require 'pry'

class Dog
  attr_accessor :id, :name, :breed
  @@all = []

  def initialize(id:nil, name:, breed:)
    self.id = id
    self.name = name
    self.breed = breed
    @@all << self
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(props={})
    dog = self.new(props)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)[0]
    self.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_or_create_by(props={})
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, props[:name], props[:breed])
    if !dog.empty?
      dog_data = dog[0]
      self.new_from_db(dog_data)
    else
      self.create(props)
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

end
