# -*- coding: utf-8 -*-


ActiveRecord::Base.establish_connection({
  host: 'localhost',
  adapter: 'mysql2',
  user: 'root',
  password: '',
  database: 'movietruly'
})



#
# Миграци.
#


class DefaultMigration < ActiveRecord::Migration
  
  def self.up
    
    create_table :movies do |t|
      t.string :title
      t.decimal :imdb_code
      
      t.text :genres
      t.text :awards
      t.text :casts
      t.text :directors
      
      t.float :rating
      t.string :year
      t.string :trailer
      t.string :poster
      
      t.timestamps
    end
    
    
    create_table :people do |t|
      t.string :imdb_id
      
      t.string :name
      t.string :real_name
      
      t.string :birthdate
      t.string :deathdate
      
      t.string :nationality
      t.integer :height
      
      t.text :biography
      t.string :photo
      
      t.boolean :actor          # актер он или нет.
      t.boolean :director
      
      t.text :movies_as_actor           # в каких фильмах снимался.
      t.text :movies_as_director        # в каких он режиссер.
      
      t.timestamps
    end
    
    
    create_table :genres do |t|
      t.string :imdb_name
      t.text :movies
      
      t.timestamps
    end
    
    
    create_table :awards do |t|
      t.string :name
      t.references :award_type
      
      t.text :movies
      t.timestamps
    end
    
    create_table :award_types do |t|
      t.string :name
      t.timestamps
    end
    
  end
  
  
  def self.down
    drop_table :people
    drop_table :movies
    drop_table :genres
    drop_table :awards
    drop_table :award_types
  end
end



#
# Модели:
#


# Фильм.
class Movie < ActiveRecord::Base
  serialize :awards
  serialize :casts
  serialize :directors
  serialize :genres

  validates :imdb_code, uniqueness: true, presence: true

  def to_s
    "Movie##{self.imdb_code}(Awards: #{self.awards},
Cast members: #{self.casts},
Directors: #{self.directors},
Genres: #{self.genres},
Rating: #{self.rating},
Title: #{self.title},
Year: #{self.year},
Trailer url: #{self.trailer},
Poster: #{self.poster})"
  end
end


# Персона (актеры + режиссеры).
class Person < ActiveRecord::Base
  
  serialize :movies_as_actor
  serialize :movies_as_director
  
  validates :name, presence: true
  validates :imdb_id, uniqueness: true, :allow_blank => true
  
  def to_s; "#{self.imdb_id}:#{self.name}"; end
end


# Жанр.
class Genre < ActiveRecord::Base
  validates :imdb_name, uniqueness: true, presence: true
  validates_uniqueness_of :imdb_name, :case_sensitive => false
  
  def to_s; "#{self.imdb_name}"; end
end


# Награда.
class Award < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  validates_uniqueness_of :name, :case_sensitive => false
  
  belongs_to :award_type
  def to_s; "#{self.name}"; end
end


# Типы наград.
class AwardType < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  validates_uniqueness_of :name, :case_sensitive => false
  
  has_many :awards
end
