class Dog
    attr_accessor :id, :name, :breed
    def initialize(id: nil, name:, breed: )
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql =<<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql =<<-SQL
            DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql =<<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attributes_hash)
        new_doggy = Dog.new(attributes_hash)
        new_doggy.save
        new_doggy
    end

    def self.new_from_db(row)
        new_pup = Dog.new(id: row[0], name: row[1], breed: row[2])
        # new_pup.id = row[0]
        # new_pup.name = row[1]
        # new_pup.breed = row[2]
    end

    def self.find_by_id(id_to_find)
        sql =<<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL
        DB[:conn].execute(sql, id_to_find).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        pup = DB[:conn].execute(sql, name, breed)
        #if the pup variable doesn't come back empty, then just make an instance
        #and don't save to the database
        if !pup.empty?
            pup_info = pup[0]
            pup = Dog.new(id: pup_info[0], name: pup_info[1], breed: pup_info[2])
        else
            pup = self.create(name: name, breed: breed)
        end
        pup
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end