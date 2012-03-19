# -*- coding: utf-8 -*-

# Вытаскиваем фильмы из "imdb.com".
class IMDB
  
  # Вытаскиваем все с "imdb.com".
  def self.upload
    
    last = Movie.order("imdb_code").last
    @code, count = (last ? last.imdb_code - 1 : 0), (2_241_751 * 2)        # @code - последний с базы, count - чтобы точно не мало.
    
    
    error404 = 0
    while ((@code += 1) <= count)
      
      awards, movie, error = nil, nil, 0
      while ((movie = self.fetch_movie(@code); awards = self.fetch_movie_awards(movie)).nil? ||
             movie.nil? || movie.title.nil? || awards.nil?)
        
        if ((error += 1) == 5)
          error404 += 1
          break # фильма с таким кодом нет.
        end
        
        sleep 0.5
      end
      
      break if error404==5      # все фильмы скачаны.
      
      
      item = Movie.find_or_initialize_by_imdb_code(@code)
      
      item.awards     = awards
      item.title      = movie.title
      item.imdb_code  = @code
      item.casts      = movie.cast_member_ids
      item.directors  = (movie.directors.map(&:id).join(', ') rescue [])
      item.genres     = movie.genres
      item.rating     = movie.rating
      item.year       = movie.year
      item.trailer    = movie.trailer_url
      item.poster     = movie.poster
      
      item.save
      
      puts "-----------------------"
      puts item
      
      
      # режисеры:
      movie.directors.each {|d|
        person = Person.find_or_initialize_by_imdb_id(d.id)
        
        person.birthdate = d.birthdate if d.birthdate
        person.deathdate = d.deathdate if d.deathdate
        person.nationality = d.nationality if d.nationality
        person.height = d.height if d.height
        person.biography = d.biography if d.biography
        person.photo = d.photo if d.photo
        
        # фильмография:
        
        movies_as_actor = person.movies_as_actor ? person.movies_as_actor.split(",").map {|imdb_code| imdb_code.to_i} : []
        movies_as_director = person.movies_as_director ? person.movies_as_director.split(",").map {|imdb_code| imdb_code.to_i} : []
        
        movies_as_actor |= d.filmography[:actor].map {|movie| movie.id.to_i} if d.filmography[:actor]
        movies_as_director |= d.filmography[:director].map {|movie| movie.id.to_i} if d.filmography[:director]
        
        person.movies_as_actor = movies_as_actor.join(",")
        person.movies_as_director = movies_as_director.join(",")
        
        person.actor = true if movies_as_actor.size>0
        person.director = true if movies_as_director.size>0
        
        person.save
      }
      
      
      # актеры:
      if (movie.cast_member_ids and movie.cast_members and (movie.cast_member_ids.size == movie.cast_members.size)) then
        movie.cast_member_ids.each_with_index do |imdb_id, index|
          
          name = movie.cast_members[index].strip
          person = Person.find_or_initialize_by_imdb_id(imdb_id.strip, :name => name, :actor => true)
          
          movies = person.movies_as_actor ? person.movies_as_actor.split(",").map {|imdb_code| imdb_code.to_i} : []
          movies += [item.imdb_code.to_i] if !movies.include?(item.imdb_code.to_i)
          
          person.movies_as_actor = movies.join(",")
          person.save
        end
      end
      
      
      # жанры:
      movie.genres.each do |name|
        genre = Genre.find_or_initialize_by_imdb_name(name.strip)
        code = item.imdb_code.to_i
        
        movies = genre.movies ? genre.movies.split(",").map {|movie| movie.to_i} : []
        movies += [code] if !movies.include?(code)
        
        genre.movies = movies.join(",")
        genre.save
      end
      
      
      # аварды:
      movie.awards.each do |array|
        
        award_type = AwardType.find_or_create_by_name(array[:type].strip)
        award = Award.find_or_initialize_by_name(array[:award].strip, :award_type => award_type)
        
        code = item.imdb_code.to_i
        
        movies = award.movies ? award.movies.split(",").map {|movie| movie.to_i} : []
        movies += [code] if !movies.include?(code)
        
        award.movies = movies.join(",")
        award.save
      end
    end
  end
  
  
  
  private
  
  def self.fetch_movie code
    Imdb::Movie.new code
  rescue Exception => e
    puts e
  end
  
  
  def self.fetch_movie_awards movie
    movie.awards
  rescue Exception => e
    puts e
  end
  
end
