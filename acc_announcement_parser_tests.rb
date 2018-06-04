require "test/unit"
require_relative "acc_announcement_parser.rb"

class AccAnnouncementParserTest < Test::Unit::TestCase
    SIMPLE_HTML = %{<p>În legătură cu lorem ipsum <strong>3 iunie 2050</strong></p>}
    SIMPLE_TEXT = 'În legătură cu lorem ipsum 3 iunie 2050'

    TRICKY_HTML = %{
    <p>Lorem <b>ipusm</b>
        <ul>
            <li><strong>31 august 1989</strong></li>
        </ul>
        <strong>01</strong><strong> Septembrie </strong><strong>2050</strong>
    </p>}
    TRICKY_HTML_CLEAN = %{<p>Lorem <b>ipusm</b> </p><ul> <li><strong>31 august 1989</strong></li> </ul> <strong>01 Septembrie 2050</strong>}
    TRICKY_TEXT = %{Lorem ipusm 31 august 1989 01 Septembrie 2050}

    def initialize(*args)
        super(*args)

        @simple_announcement = {
            html: SIMPLE_HTML,
            text: SIMPLE_TEXT,
            date: Date.new(2050, 6, 3)
        }

        @tricky_announcement = {
            html: TRICKY_HTML_CLEAN,
            text: TRICKY_TEXT,
            date: Date.new(2050, 9, 1)
        }
    end

    def test_regular_announcement()
        parser = AccAnnouncementParser.new
        result = parser.parse SIMPLE_HTML
        assert_equal([@simple_announcement], result)
    end

    def test_filtered_tags()
        parser = AccAnnouncementParser.new
        result = parser.parse SIMPLE_HTML + "<!-- comments --> <style> styles </style> <script> scripts </script>"
        assert_equal([@simple_announcement], result)
    end

    def test_skipped_tags()
        parser = AccAnnouncementParser.new
        result = parser.parse "<div> #{SIMPLE_HTML} </div>"
        assert_equal([@simple_announcement], result)
    end

    def test_remove_empty_p_tags()
        parser = AccAnnouncementParser.new
        result = parser.parse "<p> #{SIMPLE_HTML} <p> </p>"
        assert_equal([@simple_announcement], result)
    end

    def test_tricky_announcement()
        parser = AccAnnouncementParser.new
        result = parser.parse TRICKY_HTML
        assert_equal([@tricky_announcement], result)
    end

    def test_multiple_announcements()
        parser = AccAnnouncementParser.new
        result = parser.parse "#{SIMPLE_HTML} <hr> #{TRICKY_HTML}"
        assert_equal([@simple_announcement, @tricky_announcement], result)
    end

    def test_date_without_year()
        parser = AccAnnouncementParser.new
        result = parser.parse "Lorem ipsum 31 Decembrie"
        assert_equal(Date.new(Date.today.year, 12, 31), result[0][:date])
    end

    def parse_month month_name
        parser = AccAnnouncementParser.new
        result = parser.parse "Lorem ipsum 1 #{month_name} 2050"
        result[0][:date].month
    end

    def test_months()
        assert_equal(1, parse_month('ianuarie'))
        assert_equal(2, parse_month('Februarie'))
        assert_equal(3, parse_month('MARTIE'))
        assert_equal(4, parse_month('aprilie'))
        assert_equal(5, parse_month('mai'))
        assert_equal(6, parse_month('iunie'))
        assert_equal(7, parse_month('iulie'))
        assert_equal(8, parse_month('august'))
        assert_equal(9, parse_month('septembrie'))
        assert_equal(10, parse_month('octombrie'))
        assert_equal(11, parse_month('noiembrie'))
        assert_equal(12, parse_month('decembrie'))
    end
end
