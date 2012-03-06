require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection({
  host: 'localhost',
  adapter: 'mysql2',
  user: 'root',
  password: '',
  database: 'movietruly'
})

class DefaultMigration < ActiveRecord::Migration
  def self.up
    create_table :movies do |t|
      t.string :title
      t.decimal :imdb_code
      t.text :awards
      t.text :casts
      t.text :directors
      t.text :genres
      t.float :rating
      t.string :year
      t.string :trailer
      t.string :poster
    end
  end

  def self.down
    drop_table :movies
  end
end

# DefaultMigration.migrate :down
# DefaultMigration.migrate :up

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

def fetch_movie code
  Imdb::Movie.new code
rescue Exception => e
  puts e
end

def fetch_movie_awards movie
  movie.awards
rescue Exception => e
  puts e
end

count = 2_241_751
threads = []
@code = 0

10.times do |id|
  threads << Thread.new do
    while ((@code += 1) <= count)
      unless Movie.find_by_imdb_code(@code)
        awards, movie = nil, nil
        while ((movie = fetch_movie(@code);
            awards = fetch_movie_awards(movie)).nil? ||
            movie.nil? ||
            movie.title.nil? ||
            awards.nil?)

          sleep 0.5
        end

        item = Movie.new({
          awards: awards,
          title: movie.title,
          imdb_code: @code,
          casts: movie.cast_member_ids,
          directors: (movie.directors.map(&:id).join(', ') rescue []),
          genres: movie.genres,
          rating: movie.rating,
          year: movie.year,
          trailer: movie.trailer_url,
          poster: movie.poster
        })
        item.save

        puts item
      end
    end
  end
end

threads.map &:join
