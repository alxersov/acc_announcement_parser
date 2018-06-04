require 'date'
require 'nokogiri'

class AccAnnouncementParser
    Months = %w{ianuarie februarie martie aprilie mai iunie iulie august septembrie octombrie noiembrie decembrie}

    def initialize
        @monthNumber = {}
        Months.each {|m| @monthNumber[m] = @monthNumber.size + 1}

        @dateRegex = Regexp.new("(\\d{1,2}) (#{Months.join('|')}) ?(\\d{4})?", Regexp::IGNORECASE)
    end

    def cleanup_tree node, keep
        return if node.nil?
        node.children.each{|n| n.remove unless  n == keep }
        cleanup_tree node.parent, node
    end

    def remove_empty_p node
        node.children.each do |n|
            if n.name == 'p'
                n.remove if n.content.match?(/\A\s*\z/)
            else
                remove_empty_p n
            end
        end
    end

    def save_fragment
        remove_empty_p @dst_fragment

        html = @dst_fragment.to_html.strip
        text = @dst_fragment.content.gsub(/\s+/, ' ').strip
        dates = []

        text.scan(@dateRegex).each do |match|
            y = (match[2] || Date.today.year).to_i
            m = @monthNumber[match[1].downcase]
            d = match[0].to_i
            date = Date.new(y, m, d)
            if Date.today <= date
                dates.push(date)
            end
        end

        if 20 < text.length
            @found.push(
                html: html,
                text: text,
                date: dates.min
            )
        end
    end

    def walk(src, dst)
        case src.name
        when 'p', 'strong', 'b', 'i', 'ul', 'li', 'ol'
            last_child = dst.children[-1]
            if !last_child.nil? && last_child.name == 'strong' && last_child.name == src.name
                dst = last_child
            else
                n = Nokogiri::XML::Node.new src.name, @dst_fragment
                dst.add_child(n)
                dst = n
            end
        when 'text'
            dst.add_child(src.content.gsub(/\s+/, ' '))
        when 'hr'
            save_fragment
            cleanup_tree dst, nil
        end

        src.children.each do |c|
            walk(c, dst)
        end
    end

    def parse html
        @found = []

        @src = Nokogiri::HTML(html, nil, 'UTF-8')
        @dst_fragment = Nokogiri::HTML::DocumentFragment.parse('')
        walk(@src, @dst_fragment)
        save_fragment

        @found
    end
end
