# ACC Announcement Parser

The parser splits HTML string into separate announcements and extracts dates.

## Usage

```ruby
require 'open-uri'
require_relative 'acc_announcement_parser.rb'

ACC_URL = 'http://acc.md/mmedia/SistariProgramate.php'

html = open(ACC_URL) { |io| io.read }

parser = AccAnnouncementParser.new
announcements = parser.parse html

puts announcements
```

`parse` method returns an array of hashes:

```ruby
{
  :html=>"<p>În legătură cu...",
  :text=>"În legătură cu...",
  :date=>#<Date: 2018-06-05 ...>
}
```
