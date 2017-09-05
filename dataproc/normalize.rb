# encoding: utf-8

# Please write a tool that reads a CSV formatted file on `stdin` and
# emits a normalized CSV formatted file on `stdout`. Normalized, in this
# case, means:

# * The entire CSV is in the UTF-8 character set.
# * The Timestamp column should be formatted in ISO-8601 format.
# * The Timestamp column should be assumed to be in US/Pacific time;
#   please convert it to US/Eastern.
# * All ZIP codes should be formatted as 5 digits. If there are less
#   than 5 digits, assume 0 as the prefix.
# * All name columns should be converted to uppercase. There will be
#   non-English names.
# * The Address column should be passed through as is, except for
#   Unicode validation. Please note that there are commas in the Address
#   field, your CSV parsing will need to take that into account.
# * The columns `FooDuration` and `BarDuration` are in HH:MM:SS.MS
#   format; please convert them to a floating point seconds format.
# * The column "TotalDuration" is filled with garbage data. For each
#   row, please replace the value of TotalDuration with the sum of
#   FooDuration and BarDuration.
# * The column "Notes" is free form text input by end-users; please do
#   not perform any transformations on this column. If there are invalid
#   UTF-8 characters, please replace them with the Unicode Replacement
#   Character.

# You can assume that the input document is in UTF-8 and that any times
# that are missing timezone information are in US/Pacific. If a
# character is invalid, please replace it with the Unicode Replacement
# Character. If that replacement makes data invalid (for example,
# because it turns a date field into something unparseable), print a
# warning to `stderr` and drop the row from your output.

require 'csv'
require 'time'
require 'tzinfo'

# custom exception class
# raise if cannot normalize a line for some reason
class UnparseableError < StandardError
end 

# https://robots.thoughtbot.com/fight-back-utf-8-invalid-byte-sequences
# http://www.fileformat.info/info/unicode/char/fffd/index.htm
def normalize_utf8(strval)
    normalval = nil
    # encode string to utf-8.
    # if invalid or undefined bytes for utf-8 encountered, then replace with "U+FFFD"
    normalval = strval.to_s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: "\ufffd")
    return normalval
end

# get hour offset ('-06' or '06') of named time zone ('America/New_York')
def tz_offset(tzname)
    # get hours offset of named timezone
    # with TZInfo we dont have to worry if it is daylight saving time or not
    tzinfo = TZInfo::Timezone.get(tzname)
    period = tzinfo.current_period
    offset = (period.offset.utc_total_offset/3600) # offset in hours

    # return a zero-padded number
    if( offset >= 0 )
        return "%02d" % offset
    else
        return "-%02d" % offset.abs
    end
end

# convert PACIFIC to EASTERN timezone
def normalize_ts(strval)
    normalval = nil
    strval_w_tz = "#{strval} #{tz_offset('America/Los_Angeles')}"
    input_format = "%m/%d/%y %l:%M:%S %p %z"
    
    dt_pacific = DateTime.strptime(strval_w_tz, input_format) rescue nil
    if( dt_pacific == nil )
        puts strval_w_tz
        raise UnparseableError.new("Unknown timestamp value: #{strval}")
    end

    dt_eastern = dt_pacific.to_time.utc.localtime("#{tz_offset('America/New_York')}:00")
    normalval = dt_eastern.iso8601
    return normalval
end

# captialize each word in strval
def normalize_proper_name(strval)
    normalval = nil
    words = strval.split(/\w+/)
    normalval = words.map{|word| word.capitalize}.join(" ")
    return normalval
end

# return 5-digit zipcode
def normalize_zip(strval)
    normalval = nil

    upto_five_digits = /^\d{1,5}$/ 
    if( strval.match(upto_five_digits).nil? )
        raise UnparseableError.new("Unknown zipcode value: #{strval}")
    end

    normalval = "%05d" % strval 

    return normalval
end

# return floating point seconds
def normalize_duration(strval)
    normalval = nil
    # split into hours, minutes, and seconds
    parts = strval.split(":")

    if( parts.size !=  3)
        raise UnparseableError.new("Unknown duration value: #{strval}")
    end

    # sum up parts into seconds
    sum = (parts[0].to_i*3600) + (parts[1].to_i*60) + parts[2].to_f
    normalval = sum.to_s

    return normalval
end



# expected columns
default_cols = 'Timestamp,Address,ZIP,FullName,FooDuration,BarDuration,TotalDuration,Notes'

# verify arguments are provided
# bail if arguments not given
filepath = ARGV[0]
newfilepath = ARGV[1]
if( filepath.empty? || newfilepath.empty? )
  puts "Usage: normalize.rb path/to/file.csv path/to/new_file.csv"
  return
end

# ok; lets process the file
#

# using lookaheads, match commas but not those inside quotes
# https://stackoverflow.com/a/632552
unquoted_commas = /,(?=(?:[^"]|"[^"]*")*$)/

# open new file for writing
File.open(newfilepath, "w") do |outfile|
    col_list = []
    linenum = 0

    # open input file as binary reading so we can handle invalid utf-8 encodings
    File.open(filepath, 'rb') do |infile|

        # translate each input line and write to output file
        infile.each do |binary_line|
            linenum += 1

            # convert binary data to array of normalized utf-8 strings
            row = normalize_utf8(binary_line).split(unquoted_commas)

            # setup
            new_row = []
            total = "0.0"
            bar = "0.0"
            foo = "0.0"

            # if first line, then just get the column names in this iteration of loop
            if( linenum == 1 )
                col_list = row
                new_row << row
                outfile.write( new_row.join(',') )
                first_line = false
                next
            end

            # translate each column in order they appear
            col_list.each_with_index do |name, index|
                new_value = ""
                begin
                    case name
                    when "Timestamp"
                        new_value = normalize_ts(row[index])
                    when "ZIP"
                        new_value = normalize_zip(row[index])
                    when "FullName"
                        new_value = normalize_proper_name(row[index])
                    when "FooDuration"
                        foo = normalize_duration(row[index])
                        new_value = foo
                    when "BarDuration"
                        bar = normalize_duration(row[index])
                        new_value = bar
                    when "TotalDuration"
                        # use fill-in text for now; replace with total at end
                        new_value = ">>TOTAL-DURATION-HERE<<"
                    else
                        # pass-thru
                        # - Address
                        # - Notes
                        if( row[index].to_s.empty? == false )
                            new_value = row[index]
                        else
                            new_value = ""
                        end
                    end
                rescue UnparseableError => msg
                    # print any errors to stderr and skip to the next line
                    STDERR.puts "line:#{linenum} col:#{name} #{msg}"
                    STDERR.puts "\t\"#{row[index]}\""
                    new_row = []
                    break
                end

                # add to the row
                new_row << new_value
            end

            if( new_row.size > 0 )
                # add newline to last column if it doesn't have one already
                if( new_row.last.end_with?('\n') == false )
                    str = new_row.pop
                    new_row << str + "\n"
                end

                # write row to output file
                total_duration = bar.to_f + foo.to_f
                outfile.write( new_row.join(',').gsub(">>TOTAL-DURATION-HERE<<", total_duration.to_s) )
            end
        end
    end
end
