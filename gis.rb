#!/usr/bin/env ruby

class Track
  attr_accessor :name, :json, :segments

  def initialize(args)
    @name = args[:name] || ''
    @segments = args[:segments]
    @json = args[:json]
  end
    
  def get_json
    json.get_json(self)
  end
end

class TrackJson
  #Pretty much just refactored the original to be more defined than single letter variables
  def get_json(track)
    json = '{"type": "Feature", '

    if !track.name.empty?
      json += '"properties": {"title": "' + track.name + '"},'
    end

    json += '"geometry": {"type": "MultiLineString", "coordinates": ['
    
    track.segments.each_with_index do |segment, index|
      if index > 0
        json += ","
      end

      json += '['

      track_json_segment = ''

      segment.coordinates.each do |coordinate|
        if !track_json_segment.empty?
          track_json_segment += ','
        end
        # longitude, latitude. Cool functions
        track_json_segment += "[#{coordinate.lon}, #{coordinate.lat}"
        
        if coordinate.ele != 100000
          track_json_segment += ",#{coordinate.ele}"
        end
        
        track_json_segment += ']'
      end

      json += track_json_segment
      json+= ']'
    end
    json + ']}}'
  end

end


class TrackSegment
  attr_reader :coordinates
  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Point

  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end

class Waypoint
  attr_reader :lat, :lon, :ele, :name, :type, :json

  def initialize(args)
    @lat = args[:lat]
    @lon = args[:lon]
    @ele = args[:ele] || 100000
    @name = args[:name] || ''
    @type = args[:type] || ''
    @json = args[:json]
  end

  def get_json
    json.get_json(self)
  end
end

#Similar to above, instead make it two separate classes. like TrackSegment but TrackWaypoint
class TrackWaypoint
  def get_json(waypoint)
    json = '{"type": "Feature","geometry": {"type": "Point","coordinates": '
    #These were backwards. should be Lat, Lon. 
    json += "[#{waypoint.lat},#{waypoint.lon}"
    
    if waypoint.ele != 100000
      json += ",#{waypoint.ele}"
    end
    
    json += ']},'

    if !waypoint.name.empty? or !waypoint.type.empty?
      json += '"properties": {'

      if !waypoint.name.empty?
        json += '"title": "' + waypoint.name + '"'
      end

      if !waypoint.type.empty?
        
        if !waypoint.name.empty?
          json += ','
        end

        json += '"icon": "' + waypoint.type + '"'
      end
      json += '}'
    end
    json += "}"
    # return json
  end
end

class World

  def initialize(name, features)
    @name = name
    @features = features
  end

  def add_feature(feature)
    @features.append(type)
  end

  def to_geojson()
    string = '{"type": "FeatureCollection","features": ['
    
    @features.each_with_index do |feature, index|
      if index != 0
        string +=","
      end
      string += feature.get_json
    end
    string + "]}"
  end

end

def main()
  json = TrackWaypoint.new
  waypoint1 = Waypoint.new(:lat => -121.5, :lon =>45.5, :ele => 30, :name => "home", :type => "flag", :json => json)
  waypoint2 = Waypoint.new(:lat => -121.5, :lon =>45.6, :ele => 100000, :name => "store", :type => "dot", :json => json)
  
  ts1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  ts2 = [ 
    Point.new(-121, 45), 
    Point.new(-121, 46), 
  ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  track_segment1 = TrackSegment.new(ts1)
  track_segment2 = TrackSegment.new(ts2)
  track_segment3 = TrackSegment.new(ts3)
  json = TrackJson.new

  t = Track.new(:segments => [track_segment1, track_segment2], :name => "track 1", :json => json)
  t2 = Track.new(:segments => [track_segment3], :name => "track 2", :json => json)

  world = World.new("My Data", [waypoint1, waypoint2, t, t2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

