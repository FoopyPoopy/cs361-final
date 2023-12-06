require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase

  def test_waypoints
    json = TrackWaypoint.new
    w = Waypoint.new(:lat => -121.5, :lon => 45.5, :ele => 30, :name => "home", :type => "flag", :json => json)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)

    w = Waypoint.new(:lat => -121.5, :lon => 45.5, :ele => 100000, :name => '', :type => "flag", :json => json)
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)

    w = Waypoint.new(:lat => -121.5, :lon => 45.5, :ele => 100000, :name => "store", :type => '', :json => json)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)
  end

  def test_tracks
    ts1 = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ]

    ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

    ts3 = [
      Point.new(-121, 45.5),
      Point.new(-122, 45.5),
    ]

    track_segment1 = TrackSegment.new(ts1)
    track_segment2 = TrackSegment.new(ts2)
    track_segment3 = TrackSegment.new(ts3)
    json = TrackJson.new

    t = Track.new(:segments => [track_segment1, track_segment2], :name => "track 1", :json => json)
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(t.get_json)
    assert_equal(expected, result)

    t = Track.new(:segments => [track_segment3], :name => "track 2", :json => json)
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    result = JSON.parse(t.get_json)
    assert_equal(expected, result)
  end

  def test_world
    json = TrackWaypoint.new
    w = Waypoint.new(:lat => -121.5, :lon => 45.5, :ele => 30, :name => "home", :type => "flag", :json => json)
    w2 = Waypoint.new(:lat => -121.5, :lon => 45.6, :ele => 100000, :name => "store", :type => '', :json => json)
    ts1 = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ]

    ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

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

    w = World.new("My Data", [w, w2, t, t2])

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(w.to_geojson)
    assert_equal(expected, result)
  end

end
