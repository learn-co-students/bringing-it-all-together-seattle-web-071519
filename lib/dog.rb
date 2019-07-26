require 'pry'

class Dog
    attr_accessor :name, :breed, :id

    def initialize(hash)
        @name = hash[:name]
        @breed = hash[:breed]
        @id = nil
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name,breed) VALUES (?,?)
        SQL
        DB[:conn].execute(sql,@name,@breed)
        @id = DB[:conn].execute("SELECT * FROM dogs ORDER BY id DESC LIMIT 1")[0][0]
        return self
    end

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
    end

    def self.new_from_db(row)
        dog = Dog.new(name: row[1], breed: row[2])
        dog.id = row[0]
        return dog
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL
        row =  DB[:conn].execute(sql,id)
        dog = Dog.new_from_db(row[0])
        return dog
    end

    def self.find_or_create_by(hash)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        results = DB[:conn].execute(sql,hash[:name],hash[:breed])
        if results.length == 0
            dog = Dog.create(hash)
            return dog
        else
            return Dog.new_from_db(results[0])
        end
    end
    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        results = DB[:conn].execute(sql,name)
        if results.length == 0
            dog = Dog.create(hash)
            return dog
        else
            return Dog.new_from_db(results[0])
        end
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ?  WHERE id = ?
        SQL
        DB[:conn].execute(sql,@name,@breed,@id)
        return self
    end
end